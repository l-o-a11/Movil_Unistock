import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';
import '../domain/sede.dart';

/// Servicio de datos para Sedes.
///
/// Consume el backend real (`GET /api/sites`). Si la petición falla, la
/// excepción se propaga hacia la UI (que muestra el mensaje de error o el
/// estado vacío correspondiente) — no hay datos mock de respaldo.
///
/// IMPORTANTE: `GET /api/sites` SIEMPRE pagina en el backend
/// (`SiteRepository.findAll`, límite por defecto = 10), a diferencia de
/// roles/insumos/categorías que devuelven un arreglo plano. La respuesta
/// real es `{ success, data: { data: [...], total, page, limit,
/// totalPages } }` — un objeto paginado ANIDADO dentro de `data`, no una
/// lista directa. Por eso se pide `limit=100` (el máximo que permite el
/// backend) y se desanida `data.data`.
class SedeService {
  final String baseUrl;
  final String _resource = 'sites';
  final AuthService _auth;

  SedeService({String? baseUrl, AuthService? auth})
      : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api',
        _auth = auth ?? AuthService();

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<List<Sede>> getSedes() async {
    final uri = Uri.parse('$baseUrl/$_resource').replace(
      queryParameters: const {'limit': '100'},
    );
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extraerLista(body);
      return data.map((e) => Sede.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Error al cargar sedes (${response.statusCode})');
  }

  Future<Sede> getSedeById(String id) async {
    final uri = Uri.parse('$baseUrl/$_resource/$id');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'])
          : Map<String, dynamic>.from(body as Map);
      return Sede.fromJson(data);
    }
    throw Exception('Error al cargar sede $id (${response.statusCode})');
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Extrae la lista de sedes tolerando 3 formas posibles de respuesta:
  /// - Arreglo plano: `[...]`
  /// - `{ data: [...] }`
  /// - `{ data: { data: [...], total, page, ... } }` (paginado — el caso
  ///   real de `/api/sites`)
  List<dynamic> _extraerLista(dynamic body) {
    if (body is List) return body;
    if (body is! Map) return [];
    final inner = body['data'];
    if (inner is List) return inner;
    if (inner is Map && inner['data'] is List) {
      return inner['data'] as List;
    }
    return [];
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
