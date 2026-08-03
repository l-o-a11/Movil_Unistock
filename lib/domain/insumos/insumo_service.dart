import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';
import 'insumo.dart';

/// Servicio de datos para Insumos.
///
/// Consume el backend real (`GET /api/insumos`). Si la petición falla, la
/// excepción se propaga hacia la UI (que muestra el mensaje de error o el
/// estado vacío correspondiente) — no hay datos mock de respaldo.
class InsumoService {
  final String baseUrl;
  final String _resource = 'insumos';
  final AuthService _auth;

  InsumoService({String? baseUrl, AuthService? auth})
      : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api',
        _auth = auth ?? AuthService();

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<List<Insumo>> getInsumos({String? query}) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) params['search'] = query;

    final uri = Uri.parse('$baseUrl/$_resource').replace(
      queryParameters: params.isEmpty ? null : params,
    );

    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data =
          body is List ? body : (body is Map ? (body['data'] as List? ?? []) : []);
      return data
          .map((e) => Insumo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Error al cargar insumos (${response.statusCode})');
  }

  Future<Insumo> getInsumoById(String id) async {
    final uri = Uri.parse('$baseUrl/$_resource/$id');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'])
          : Map<String, dynamic>.from(body as Map);
      return Insumo.fromJson(data);
    }

    throw Exception('Error al cargar insumo $id (${response.statusCode})');
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

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
