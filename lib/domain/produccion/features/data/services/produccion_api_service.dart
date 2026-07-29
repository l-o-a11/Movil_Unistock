import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/shared/services/auth_service.dart';

import '../../domain/entities/orden_detail_entity.dart';
import '../models/orden_model.dart';
import '../models/orden_detail_model.dart';
import '../datasources/orden_local_datasource.dart';

/// Servicio de API para producción.
/// Intenta consumir el backend REST; si no está disponible, cae en el
/// datasource local para mantener la app funcional en desarrollo.
class ProduccionApiService implements OrdenLocalDataSource {
  final String baseUrl;
  final OrdenLocalDataSource _local;
  final AuthService _auth;

  ProduccionApiService({
    this.baseUrl = 'http://10.0.2.2:3000/api',
    OrdenLocalDataSource? local,
    AuthService? auth,
  }) : _local = local ?? OrdenLocalDataSourceImpl(),
       _auth = auth ?? AuthService();

  @override
  Future<List<OrdenModel>> getOrdenes({
    String? estado,
    String? tipo,
    String? query,
  }) async {
    try {
      final params = <String, String>{};
      if (estado != null) params['estado'] = estado;
      if (tipo != null) params['tipo'] = tipo;
      if (query != null && query.isNotEmpty) params['q'] = query;

      final uri = Uri.parse(
        '$baseUrl/produccion/ordenes',
      ).replace(queryParameters: params);
      final response = await http
          .get(uri, headers: await _authHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        List<dynamic> data = [];
        if (body is List)
          data = body;
        else if (body is Map && body['data'] is List)
          data = (body['data'] as List);
        if (data.isNotEmpty) {
          return data.map((e) => OrdenModel.fromJson(e)).toList();
        }
        // Fallback: if API returns an object with the entity under 'data'
        // and it's a single item, try to map it as a single-element list.
        if (body is Map && body['data'] is Map) {
          return [OrdenModel.fromJson(body['data'])];
        }
      }
    } catch (_) {}
    return _local.getOrdenes(estado: estado, tipo: tipo, query: query);
  }

  @override
  Future<OrdenDetailEntity?> getOrdenDetail(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/produccion/ordenes/$id');
      final response = await http
          .get(uri, headers: await _authHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body is Map && body['data'] is Map) {
          return OrdenDetailModel.fromJson(
            Map<String, dynamic>.from(body['data']),
          );
        }
        if (body is Map)
          return OrdenDetailModel.fromJson(Map<String, dynamic>.from(body));
      }
    } catch (_) {}
    return _local.getOrdenDetail(id);
  }

  /// Avanza la orden al [nuevoEstado] — rol Gerente.
  /// Espejo de `ProductionAPIClient.changeOrderStatus` (PATCH .../estado).
  @override
  Future<OrdenDetailEntity?> avanzarEstado(String id, String nuevoEstado) async {
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
    throw Exception('No se pudo avanzar la orden (HTTP ${response.statusCode})');
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
    throw Exception('No se pudo confirmar la etapa (HTTP ${response.statusCode})');
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
