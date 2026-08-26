import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';

import '../../domain/entities/proveedor_entity.dart';

/// Servicio de API para proveedores.
/// Consume únicamente el backend REST. Si la petición falla, la excepción
/// se propaga hacia la UI (que muestra el estado de error o vacío) — NO hay
/// datos mock de respaldo, para no mostrar información quemada en la vista.
class ProveedoresApiService {
  // FIX: antes la URL por defecto era siempre http://10.0.2.2:3000/api
  // (solo sirve en el emulador de Android contra un backend LOCAL). Ahora
  // usa ApiConfig.baseUrl, la misma fuente de verdad que el resto de la
  // app — así Proveedores también pega contra el backend en Render.
  final String baseUrl;
  final AuthService _auth;

  ProveedoresApiService({String? baseUrl, AuthService? auth})
    : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api',
      _auth = auth ?? AuthService();

  // ── Obtener lista de proveedores ──────────────────────────────────────────
  Future<List<ProveedorEntity>> getAll({String? query}) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) {
      params['search'] = query; // La API usa 'search'
    }

    final uri = Uri.parse(
      '$baseUrl/suppliers',
    ).replace(queryParameters: params.isEmpty ? null : params);

    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body is List
          ? body
          : (body['data'] as List? ?? []);
      return data
          .map((e) => _mapFromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Error al cargar proveedores (${response.statusCode})');
  }

  // ── Obtener detalle de un proveedor ───────────────────────────────────────
  Future<ProveedorEntity?> getById(String id) async {
    final uri = Uri.parse('$baseUrl/suppliers/$id');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body is Map && body.containsKey('data')
          ? body['data'] as Map<String, dynamic>
          : body as Map<String, dynamic>;
      return _mapFromJson(data);
    }

    throw Exception('Error al cargar proveedor $id (${response.statusCode})');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
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

  /// Mapea la respuesta real del backend (snake_case) a la entidad Flutter.
  /// Campos de la API: id, nit, nombre_de_empresa, nombre_del_contacto,
  ///                   direccion, telefono, correo, sitio_web, activo
  ProveedorEntity _mapFromJson(Map<String, dynamic> json) {
    final activo = json['activo'];
    final estado = (activo == true || activo == 'activo')
        ? ProveedorEstado.activo
        : ProveedorEstado.inactivo;

    return ProveedorEntity(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nit: (json['nit'] ?? '').toString(),
      nombre: (json['nombre_de_empresa'] ?? json['nombre'] ?? '').toString(),
      contacto: (json['nombre_del_contacto'] ?? json['contacto'] ?? '')
          .toString(),
      direccion: (json['direccion'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      sitioWeb: (json['sitio_web'] ?? json['sitioWeb'] ?? '').toString(),
      estado: estado,
    );
  }
}
