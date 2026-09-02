import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';
import '../domain/insumo.dart';

/// Servicio de datos para Insumos.
///
/// Consume el backend real (`GET /api/insumos`). Si la petición falla, la
/// excepción se propaga hacia la UI (que muestra el mensaje de error o el
/// estado vacío correspondiente) — no hay datos mock de respaldo.
///
/// El backend NO popula el campo `categoria` de cada insumo (llega como
/// ObjectId plano), así que este servicio resuelve los nombres aparte
/// consultando `GET /insumos/catalogos/categorias` y los inyecta en cada
/// [Insumo] antes de devolverlos.
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
      final insumos =
          data.map((e) => Insumo.fromJson(e as Map<String, dynamic>)).toList();
      return _enriquecerCategorias(insumos);
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
      final insumo = Insumo.fromJson(data);
      final enriquecidos = await _enriquecerCategorias([insumo]);
      return enriquecidos.first;
    }

    throw Exception('Error al cargar insumo $id (${response.statusCode})');
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Completa `categoriaNombre` de cada insumo consultando el catálogo de
  /// categorías. Si el catálogo falla, se devuelven los insumos tal cual
  /// (solo con el id de categoría) para no romper la carga principal.
  Future<List<Insumo>> _enriquecerCategorias(List<Insumo> insumos) async {
    if (insumos.every((i) => i.categoriaId.isEmpty)) return insumos;
    try {
      final mapa = await _fetchCategoriasMap();
      return insumos
          .map((i) => i.copyWith(categoriaNombre: mapa[i.categoriaId]))
          .toList();
    } catch (_) {
      return insumos;
    }
  }

  Future<Map<String, String>> _fetchCategoriasMap() async {
    final uri = Uri.parse('$baseUrl/$_resource/catalogos/categorias');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return {};

    final body = jsonDecode(response.body);
    final List<dynamic> data =
        body is List ? body : (body is Map ? (body['data'] as List? ?? []) : []);

    final mapa = <String, String>{};
    for (final c in data) {
      if (c is Map) {
        final id = (c['id'] ?? c['_id'])?.toString();
        final nombre = c['nombre']?.toString();
        if (id != null && nombre != null) mapa[id] = nombre;
      }
    }
    return mapa;
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
