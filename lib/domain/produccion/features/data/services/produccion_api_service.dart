import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';

import '../../domain/entities/orden_detail_entity.dart';
import '../models/orden_model.dart';
import '../models/orden_detail_model.dart';
import '../datasources/orden_local_datasource.dart';

/// Error de la API de producción (respuesta HTTP no-200, o de red).
///
/// Se lanza ante una respuesta HTTP no exitosa o de red. La pantalla de
/// producción solo debe mostrar datos obtenidos del backend real.
class ProduccionApiException implements Exception {
  final String message;
  const ProduccionApiException(this.message);
  @override
  String toString() => message;
}

/// Servicio de API para producción.
///
/// Estrategia (consistente con Compras/Insumos):
/// - HTTP 200 → retorna los datos REALES de la base de datos (incluyendo
///   lista vacía).
/// - Error HTTP (401/404/500) → lanza [ProduccionApiException] para que la
///   UI muestre el error real.
/// - Error de RED (sin conexión / backend caído) → lanza
///   [ProduccionApiException]; no se usan datos locales de respaldo.
class ProduccionApiService implements OrdenLocalDataSource {
  final String baseUrl;
  final AuthService _auth;

  ProduccionApiService({String? baseUrl, AuthService? auth})
    : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api',
      _auth = auth ?? AuthService();

  @override
  Future<List<OrdenModel>> getOrdenes({
    String? estado,
    String? tipo,
    String? query,
  }) async {
    final params = <String, String>{};
    if (estado != null) params['estado'] = estado;
    if (tipo != null) params['tipo'] = tipo;
    if (query != null && query.isNotEmpty) params['q'] = query;

    // El endpoint está paginado. Pedir solo la primera página ocultaba
    // órdenes válidas y hacía que Producción pareciera incompleta.
    const limit = 1000;
    final byId = <String, OrdenModel>{};
    var page = 1;
    var total = 0;

    while (page <= 500) {
      final response = await _getProduction(
        '/ordenes',
        queryParameters: {...params, 'page': '$page', 'limit': '$limit'},
      );

      if (response.statusCode != 200) {
        throw ProduccionApiException(
          'No se pudieron cargar las órdenes (HTTP ${response.statusCode})',
        );
      }

      final body = json.decode(response.body);
      final data = _extractList(body);
      total = _extractTotal(body, current: total);
      if (data.isEmpty) break;

      var added = 0;
      for (final raw in data.whereType<Map>()) {
        final orden = OrdenModel.fromJson(Map<String, dynamic>.from(raw));
        // El backend siempre entrega id; se conserva una clave única como
        // protección adicional para respuestas malformadas.
        final key = orden.id.isEmpty ? '__page_${page}_$added' : orden.id;
        if (!byId.containsKey(key)) {
          byId[key] = orden;
          added++;
        }
      }

      if ((total > 0 && byId.length >= total) || added == 0) break;
      page++;
    }
    return byId.values.toList();
  }

  @override
  Future<OrdenDetailEntity?> getOrdenDetail(String id) async {
    final response = await _getProduction('/ordenes/$id');

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = _extractOne(body);
      if (data.isEmpty) return null;
      return OrdenDetailModel.fromJson(data);
    }

    if (response.statusCode == 404) return null;

    throw ProduccionApiException(
      'No se pudo cargar el detalle de la orden (HTTP ${response.statusCode})',
    );
  }

  /// Extrae una lista tolerando varios formatos de respuesta del backend:
  /// `[...]`, `{data:[...]}`, `{data:{data:[...]}}`, `{docs:[...]}`,
  /// `{results:[...]}`, `{ordenes:[...]}`.
  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      if (raw['data'] is List) return raw['data'] as List;
      if (raw['data'] is Map) {
        final inner = raw['data'] as Map;
        for (final key in ['data', 'docs', 'results', 'ordenes', 'items']) {
          if (inner[key] is List) return inner[key] as List;
        }
      }
      for (final key in ['docs', 'results', 'ordenes', 'items']) {
        if (raw[key] is List) return raw[key] as List;
      }
    }
    return const [];
  }

  int _extractTotal(dynamic raw, {required int current}) {
    if (raw is! Map) return current;
    int? fromMap(Map map) {
      final value = map['total'] ?? map['totalDocs'] ?? map['count'] ?? map['totalCount'];
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    final direct = fromMap(raw);
    if (direct != null) return direct > current ? direct : current;
    final nested = raw['data'];
    if (nested is Map) {
      final value = fromMap(nested);
      if (value != null && value > current) return value;
    }
    return current;
  }

  /// El proyecto tiene dos montajes de servidor: el activo en `app.js` usa
  /// `/api/produccion`, mientras otro montaje histórico usa
  /// `/api/production`. Se prueba el alias alterno únicamente ante 404; nunca
  /// se sustituyen datos reales por mocks.
  Future<http.Response> _getProduction(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    http.Response? notFound;
    Object? networkError;

    for (final resource in const ['produccion', 'production']) {
      final uri = Uri.parse('$baseUrl/$resource$path').replace(
        queryParameters: queryParameters,
      );
      try {
        final response = await http
            .get(uri, headers: await _authHeaders)
            .timeout(const Duration(seconds: 10));
        if (response.statusCode != 404) return response;
        notFound = response;
      } catch (error) {
        networkError = error;
      }
    }

    if (notFound != null) return notFound;
    throw ProduccionApiException(
      'No se pudo conectar con el servidor de producción${networkError == null ? '' : ': $networkError'}',
    );
  }

  /// Extrae un objeto tolerando distintos formatos de respuesta.
  Map<String, dynamic> _extractOne(dynamic raw) {
    if (raw is Map) {
      if (raw['data'] is Map) {
        return Map<String, dynamic>.from(raw['data'] as Map);
      }
      return Map<String, dynamic>.from(raw);
    }
    return const {};
  }

  /// Avanza la orden al [nuevoEstado] — rol Gerente.
  /// Espejo de `ProductionAPIClient.changeOrderStatus` (PATCH .../estado).
  @override
  Future<OrdenDetailEntity?> avanzarEstado(
    String id,
    String nuevoEstado,
  ) async {
    final userId = await _auth.getUserId();
    final uri = Uri.parse('$baseUrl/produccion/ordenes/$id/estado');
    final response = await http
        .patch(
          uri,
          headers: await _authHeaders,
          body: json.encode({'estado': nuevoEstado, 'id_usuario': userId}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = (body is Map && body['data'] != null) ? body['data'] : body;
      if (data is Map) {
        return OrdenDetailModel.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ProduccionApiException(
      'No se pudo avanzar la orden (HTTP ${response.statusCode})',
    );
  }

  /// El empleado asignado confirma que terminó la etapa actual. NO cambia
  /// el estado — solo marca `etapaConfirmada: true`. Espejo de
  /// `ProductionAPIClient.confirmarEtapa` (PATCH .../confirmar-etapa).
  @override
  Future<OrdenDetailEntity?> confirmarEtapa(String id) async {
    final userId = await _auth.getUserId();
    final uri = Uri.parse('$baseUrl/produccion/ordenes/$id/confirmar-etapa');
    final response = await http
        .patch(
          uri,
          headers: await _authHeaders,
          body: json.encode({'id_usuario': userId}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = (body is Map && body['data'] != null) ? body['data'] : body;
      if (data is Map) {
        return OrdenDetailModel.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw ProduccionApiException(
      'No se pudo confirmar la etapa (HTTP ${response.statusCode})',
    );
  }

  Future<Map<String, String>> get _authHeaders async {
    final token = await _auth.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
