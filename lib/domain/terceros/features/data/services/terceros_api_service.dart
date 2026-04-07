import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/tercero_entity.dart';
import '../../domain/entities/tercero_detail_entity.dart';
import '../../domain/entities/tercero_produccion_entity.dart';
import '../datasources/tercero_local_datasource.dart';
import '../models/tercero_model.dart';

/// Servicio de API para terceros.
/// Intenta consumir el backend REST; si no está disponible, cae en el
/// datasource local (mock) para mantener la app funcional en desarrollo.
class TercerosApiService {
  final String baseUrl;
  final TerceroLocalDataSource _local;

  TercerosApiService({
    this.baseUrl = 'https://api.example.com',
    TerceroLocalDataSource? local,
  }) : _local = local ?? TerceroLocalDataSourceImpl();

  // ── Obtener lista de terceros ─────────────────────────────────────────────

  Future<List<TerceroEntity>> getTerceros({String? query}) async {
    try {
      final params = <String, String>{};
      if (query != null && query.isNotEmpty) params['q'] = query;

      final uri =
          Uri.parse('$baseUrl/terceros').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => TerceroModel.fromJson(e)).toList();
      }
    } catch (_) {
      // Fallback silencioso al datasource local
    }

    return _local.getTerceros(query: query);
  }

  // ── Obtener detalle de un tercero ─────────────────────────────────────────

  Future<TerceroDetailEntity?> getTerceroDetail(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/terceros/$id');
      final response = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _mapDetailFromJson(data);
      }
    } catch (_) {
      // Fallback silencioso al datasource local
    }

    return _local.getTerceroDetail(id);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  TerceroDetailEntity _mapDetailFromJson(Map<String, dynamic> json) {
    return TerceroDetailEntity(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      contacto: json['contacto'] as String,
      nit: json['nit'] as String,
      direccion: json['direccion'] as String,
      telefono: json['telefono'] as String,
      estado: TerceroEstado.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => TerceroEstado.activo,
      ),
      producciones: (json['producciones'] as List<dynamic>?)
              ?.map((p) => TerceroProduccionEntity(
                    corte: p['corte'] as String,
                    fecha: DateTime.parse(p['fecha'] as String),
                    ordenId: p['ordenId'] as String,
                  ))
              .toList() ??
          [],
    );
  }
}
