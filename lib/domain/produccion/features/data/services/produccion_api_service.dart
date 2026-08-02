import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';

import '../../domain/entities/orden_detail_entity.dart';
import '../models/orden_model.dart';
import '../models/orden_detail_model.dart';
import '../datasources/orden_local_datasource.dart';

/// Error de la API de producción (respuesta HTTP no-200).
///
/// Se lanza en lugar de caer al mock local para que la UI muestre el error
/// real (401, 500, etc.) — igual que Compras/Insumos.
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
///   lista vacía — NUNCA mock).
/// - Error HTTP (401/404/500) → lanza [ProduccionApiException] para que la
///   UI muestre el error real.
/// - Error de RED (sin conexión / backend caído) → fallback al datasource
///   local (mock) para mantener la app funcional en desarrollo.
class ProduccionApiService implements OrdenLocalDataSource {
  final String baseUrl;
  final OrdenLocalDataSource _local;
  final AuthService _auth;

  ProduccionApiService({
    String? baseUrl,
    OrdenLocalDataSource? local,
    AuthService? auth,
  }) : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api',
       _local = local ?? OrdenLocalDataSourceImpl(),
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

    final uri = Uri.parse(
      '$baseUrl/produccion/ordenes',
    ).replace(queryParameters: params.isEmpty ? null : params);

    http.Response response;
    try {
      response = await http
          .get(uri, headers: await _authHeaders)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Red no disponible (emulador sin backend) → fallback local/dev.
      return _local.getOrdenes(estado: estado, tipo: tipo, query: query);
    }

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = _extractList(body);
      return data
          .whereType<Map>()
          .map((e) => OrdenModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw ProduccionApiException(
      'No se pudieron cargar las órdenes (HTTP ${response.statusCode})',
    );
  }

  @override
  Future<OrdenDetailEntity?> getOrdenDetail(String id) async {
    final uri = Uri.parse('$baseUrl/produccion/ordenes/$id');

    http.Response response;
    try {
      response = await http
          .get(uri, headers: await _authHeaders)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      return _local.getOrdenDetail(id);
    }

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
        for (final key in ['data', 'docs', 'results', 'ordenes']) {
          if (inner[key] is List) return inner[key] as List;
        }
      }
      for (final key in ['docs', 'results', 'ordenes']) {
        if (raw[key] is List) return raw[key] as List;
      }
    }
    return const [];
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
