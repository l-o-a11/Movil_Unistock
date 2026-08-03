import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/shared/services/auth_service.dart';

import '../../domain/entities/tercero_entity.dart';
import '../../domain/entities/tercero_detail_entity.dart';
import '../datasources/tercero_local_datasource.dart';
import '../models/tercero_model.dart';
import '../models/tercero_detail_model.dart';

const String kTercerosBaseUrl = 'http://10.0.2.2:3000/api';

class TercerosApiService {
  final String baseUrl;
  final TerceroLocalDataSourceImpl _local;
  final AuthService _auth;

  TercerosApiService({
    this.baseUrl = kTercerosBaseUrl,
    TerceroLocalDataSourceImpl? local,
    AuthService? auth,
  })  : _local = local ?? TerceroLocalDataSourceImpl(),
        _auth = auth ?? AuthService();

  Future<List<TerceroEntity>> getTerceros({String? query}) async {
    try {
      final params = <String, String>{'limit': '100'};
      if (query != null && query.isNotEmpty) params['search'] = query;

      final uri = Uri.parse('$baseUrl/terceros')
          .replace(queryParameters: params);

      final response = await http
          .get(uri, headers: await _authHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);
        final List<dynamic> data = _extractList(raw);
        return data
            .map((e) => TerceroModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return _local.getTerceros(query: query);
  }

  Future<TerceroDetailEntity?> getTerceroDetail(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/terceros/$id');
      final response = await http
          .get(uri, headers: await _authHeaders)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final raw = jsonDecode(response.body);
        final Map<String, dynamic> data = _extractOne(raw);
        return TerceroDetailModel.fromJson(data);
      }
    } catch (_) {}
    return _local.getTerceroDetail(id);
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      if (raw['data'] is List) return raw['data'] as List;
      if (raw['data'] is Map) {
        final inner = raw['data'] as Map;
        if (inner['data'] is List) return inner['data'] as List;
      }
    }
    return [];
  }

  Map<String, dynamic> _extractOne(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is Map<String, dynamic>) return raw['data'] as Map<String, dynamic>;
      return raw;
    }
    return {};
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