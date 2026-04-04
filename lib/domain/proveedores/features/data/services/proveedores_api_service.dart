import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/proveedor_entity.dart';
import '../datasources/proveedor_datasource.dart';

/// Servicio de API para proveedores.
/// Intenta consumir el backend REST; si no está disponible, cae en el
/// datasource local (mock) para mantener la app funcional en desarrollo.
class ProveedoresApiService {
  final String baseUrl;
  final ProveedorDataSource _local;

  ProveedoresApiService({
    this.baseUrl = 'https://api.example.com',
    ProveedorDataSource? local,
  }) : _local = local ?? ProveedorDataSource();

  // ── Obtener lista de proveedores ──────────────────────────────────────────

  Future<List<ProveedorEntity>> getAll({String? query}) async {
    try {
      final params = <String, String>{};
      if (query != null && query.isNotEmpty) params['q'] = query;

      final uri = Uri.parse('$baseUrl/proveedores')
          .replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => _mapFromJson(e)).toList();
      }
    } catch (_) {
      // Fallback silencioso al datasource local
    }

    return _local.getAll(query: query);
  }

  // ── Obtener detalle de un proveedor ───────────────────────────────────────

  Future<ProveedorEntity?> getById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/proveedores/$id');
      final response = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _mapFromJson(data);
      }
    } catch (_) {
      // Fallback silencioso al datasource local
    }

    // Busca en mock local por id
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

  ProveedorEntity _mapFromJson(Map<String, dynamic> json) {
    return ProveedorEntity(
      id: json['id'] as String,
      nit: json['nit'] as String,
      nombre: json['nombre'] as String,
      contacto: json['contacto'] as String,
      direccion: json['direccion'] as String,
      telefono: json['telefono'] as String,
      correo: json['correo'] as String,
      sitioWeb: json['sitioWeb'] as String,
      estado: ProveedorEstado.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => ProveedorEstado.activo,
      ),
    );
  }
}
