import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';

import '../../domain/entities/proveedor_entity.dart';
import '../datasources/proveedor_datasource.dart';

/// Servicio de API para proveedores.
/// Intenta consumir el backend REST; si no está disponible, cae en el
/// datasource local (mock) para mantener la app funcional en desarrollo.
class ProveedoresApiService {
  // FIX: antes la URL por defecto era siempre http://10.0.2.2:3000/api
  // (solo sirve en el emulador de Android contra un backend LOCAL). Ahora
  // usa ApiConfig.baseUrl, la misma fuente de verdad que el resto de la
  // app — así Proveedores también pega contra el backend en Render.
  final String baseUrl;
  final ProveedorDataSource _local;

  ProveedoresApiService({String? baseUrl, ProveedorDataSource? local})
    : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api',
      _local = local ?? ProveedorDataSource();

  // ── Obtener lista de proveedores ──────────────────────────────────────────
  Future<List<ProveedorEntity>> getAll({String? query}) async {
    try {
      final params = <String, String>{};
      if (query != null && query.isNotEmpty)
        params['search'] = query; // La API usa 'search'

      final uri = Uri.parse(
        '$baseUrl/suppliers',
      ).replace(queryParameters: params.isEmpty ? null : params);

      final response = await http
          .get(uri, headers: _headers)
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
    } catch (_) {
      // Fallback silencioso al datasource local
    }

    return _local.getAll(query: query);
  }

  // ── Obtener detalle de un proveedor ───────────────────────────────────────
  Future<ProveedorEntity?> getById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/suppliers/$id');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body is Map && body.containsKey('data')
            ? body['data'] as Map<String, dynamic>
            : body as Map<String, dynamic>;
        return _mapFromJson(data);
      }
    } catch (_) {
      // Fallback silencioso al datasource local
    }

    final todos = await _local.getAll();
    try {
      return todos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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
