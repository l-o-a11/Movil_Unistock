import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';
import '../domain/compra.dart';

/// Servicio de datos para Compras.
///
/// Consume el backend real (`GET /api/compras`). Si la petición falla, la
/// excepción se propaga hacia la UI (que muestra el mensaje de error o el
/// estado vacío correspondiente) — no hay datos mock de respaldo.
///
/// El backend NO incluye el nombre del proveedor en la respuesta de
/// compras (solo `proveedorId`), así que este servicio lo resuelve aparte
/// consultando `GET /api/proveedores` y lo inyecta en cada [Compra]. Para
/// el detalle de una compra puntual, también resuelve el nombre de los
/// insumos cuyo `nombre` libre venga null (solo tienen `insumoId`).
class CompraService {
  final String baseUrl;
  final String _resource = 'compras';
  final AuthService _auth;

  CompraService({String? baseUrl, AuthService? auth})
    : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api',
      _auth = auth ?? AuthService();

  // ─── Métodos públicos ─────────────────────────────────────────────────────

  Future<List<Compra>> getCompras() async {
    final uri = Uri.parse('$baseUrl/$_resource');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body is List
          ? body
          : (body is Map ? (body['data'] as List? ?? []) : []);
      final compras = data
          .map((e) => Compra.fromJson(e as Map<String, dynamic>))
          .toList();
      return _enriquecerProveedores(compras);
    }
    throw Exception('Error al cargar compras (${response.statusCode})');
  }

  Future<Compra> getCompraById(String id) async {
    final uri = Uri.parse('$baseUrl/$_resource/$id');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = (body is Map && body['data'] is Map)
          ? Map<String, dynamic>.from(body['data'])
          : Map<String, dynamic>.from(body as Map);
      var compra = Compra.fromJson(data);
      compra = (await _enriquecerProveedores([compra])).first;
      final detalles = await _enriquecerNombresInsumo(compra.detalles);
      return compra.copyWith(detalles: detalles);
    }
    throw Exception('Error al cargar compra $id (${response.statusCode})');
  }

  // ─── Helpers de enriquecimiento ────────────────────────────────────────────

  Future<List<Compra>> _enriquecerProveedores(List<Compra> compras) async {
    if (compras.every((c) => c.proveedorId.isEmpty)) return compras;
    try {
      final mapa = await _fetchProveedoresMap();
      return compras
          .map((c) => c.copyWith(proveedorNombre: mapa[c.proveedorId]))
          .toList();
    } catch (_) {
      return compras;
    }
  }

  Future<List<CompraDetalle>> _enriquecerNombresInsumo(
    List<CompraDetalle> detalles,
  ) async {
    final faltantes = detalles.where(
      (d) => (d.nombre == null || d.nombre!.isEmpty) && d.insumoId != null,
    );
    if (faltantes.isEmpty) return detalles;
    try {
      final mapa = await _fetchInsumosMap();
      return detalles
          .map((d) => d.copyWith(nombreResuelto: mapa[d.insumoId]))
          .toList();
    } catch (_) {
      return detalles;
    }
  }

  Future<Map<String, String>> _fetchProveedoresMap() async {
    final uri = Uri.parse('$baseUrl/proveedores');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return {};

    final body = jsonDecode(response.body);
    final List<dynamic> data = body is List
        ? body
        : (body is Map ? (body['data'] as List? ?? []) : []);

    final mapa = <String, String>{};
    for (final p in data) {
      if (p is Map) {
        final id = (p['id'] ?? p['_id'])?.toString();
        final nombre = p['nombre_de_empresa']?.toString();
        if (id != null && nombre != null) mapa[id] = nombre;
      }
    }
    return mapa;
  }

  Future<Map<String, String>> _fetchInsumosMap() async {
    final uri = Uri.parse('$baseUrl/insumos');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return {};

    final body = jsonDecode(response.body);
    final List<dynamic> data = body is List
        ? body
        : (body is Map ? (body['data'] as List? ?? []) : []);

    final mapa = <String, String>{};
    for (final i in data) {
      if (i is Map) {
        final id = (i['id'] ?? i['_id'])?.toString();
        final nombre = i['nombre']?.toString();
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
