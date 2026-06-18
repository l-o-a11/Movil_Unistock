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
  })  : _local = local ?? OrdenLocalDataSourceImpl(),
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

      final uri = Uri.parse('$baseUrl/produccion/ordenes').replace(queryParameters: params);
      final response = await http.get(uri, headers: await _authHeaders).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => OrdenModel.fromJson(e)).toList();
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
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return OrdenDetailModel.fromJson(data);
      }
    } catch (_) {}
    return _local.getOrdenDetail(id);
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