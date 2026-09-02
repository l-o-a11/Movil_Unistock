import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';
import '../domain/rol.dart';

/// Servicio de datos para Roles.
///
/// Consume el backend real (`GET /api/roles`). Si la petición falla, la
/// excepción se propaga hacia la UI (que muestra el mensaje de error o el
/// estado vacío correspondiente) — no hay datos mock de respaldo.
class RolService {
  final String baseUrl;
  final String _resource = 'roles';
  final AuthService _auth;

  RolService({String? baseUrl, AuthService? auth})
      : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api',
        _auth = auth ?? AuthService();

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<List<Rol>> getRoles() async {
    final uri = Uri.parse('$baseUrl/$_resource');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data =
          body is List ? body : (body is Map ? (body['data'] as List? ?? []) : []);
      return data.map((e) => Rol.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error al cargar roles (${response.statusCode})');
  }

  Future<Rol> getRolById(String id) async {
    final uri = Uri.parse('$baseUrl/$_resource/$id');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'])
          : Map<String, dynamic>.from(body as Map);
      return Rol.fromJson(data);
    }
    throw Exception('Error al cargar rol $id (${response.statusCode})');
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
