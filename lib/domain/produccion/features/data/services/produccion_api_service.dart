import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/orden_entity.dart';
import '../../domain/entities/orden_detail_entity.dart';
import '../../domain/entities/orden_referencia_entity.dart';
import '../../domain/entities/historial_entry_entity.dart';
import '../../domain/entities/ficha_costo_entity.dart';
import '../models/orden_model.dart';
import '../datasources/orden_local_datasource.dart';

/// Servicio de API para producción.
/// Intenta consumir el backend REST; si no está disponible, cae en el
/// datasource local (mock) para mantener la app funcional en desarrollo.
class ProduccionApiService {
  final String baseUrl;
  final OrdenLocalDataSource _local;

  ProduccionApiService({
    this.baseUrl = 'https://api.example.com',
    OrdenLocalDataSource? local,
  }) : _local = local ?? OrdenLocalDataSourceImpl();

  // ── Obtener lista de órdenes ──────────────────────────────────────────────

  Future<List<OrdenEntity>> getOrdenes({
    OrdenEstado? estado,
    OrdenTipo? tipo,
    String? query,
  }) async {
    try {
      final params = <String, String>{};
      if (estado != null) params['estado'] = estado.name;
      if (tipo != null) params['tipo'] = tipo.name;
      if (query != null && query.isNotEmpty) params['q'] = query;

      final uri = Uri.parse('$baseUrl/ordenes').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => OrdenModel.fromJson(e)).toList();
      }
    } catch (_) {
      // Fallback silencioso al datasource local
    }

    // Fallback: datos locales mock
    return _local.getOrdenes(estado: estado, tipo: tipo, query: query);
  }

  // ── Obtener detalle de una orden ──────────────────────────────────────────

  Future<OrdenDetailEntity?> getOrdenDetail(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/ordenes/$id');
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

    // Fallback: datos locales mock
    return _local.getOrdenDetail(id);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  OrdenDetailEntity _mapDetailFromJson(Map<String, dynamic> json) {
    return OrdenDetailEntity(
      id: json['id'] as String,
      numero: json['numero'] as int,
      unidades: json['unidades'] as int,
      estado: OrdenEstado.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => OrdenEstado.pendiente,
      ),
      tipo: OrdenTipo.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => OrdenTipo.produccion,
      ),
      cliente: json['cliente'] as String?,
      fechaEntrega: json['fechaEntrega'] != null
          ? DateTime.tryParse(json['fechaEntrega'])
          : null,
      refCorte: json['refCorte'] as String?,
      ref: json['ref'] as String?,
      fechaEstado: json['fechaEstado'] != null
          ? DateTime.tryParse(json['fechaEstado'])
          : null,
      progreso: (json['progreso'] as num).toDouble(),
      etapaActual: json['etapaActual'] as int,
      referencias: (json['referencias'] as List<dynamic>?)
              ?.map((r) => _mapReferencia(r))
              .toList() ??
          [],
      historial: (json['historial'] as List<dynamic>?)
              ?.map((h) => _mapHistorial(h))
              .toList() ??
          [],
      fichaCosto: json['fichaCosto'] != null
          ? _mapFicha(json['fichaCosto'])
          : null,
    );
  }

  OrdenReferenciaEntity _mapReferencia(Map<String, dynamic> r) {
    return OrdenReferenciaEntity(
      codigo: r['codigo'] as String,
      cantidad: r['cantidad'] as int,
      color: _parseColor(r['colorHex'] as String? ?? '#000000'),
      colorName: r['colorName'] as String,
    );
  }

  HistorialEntryEntity _mapHistorial(Map<String, dynamic> h) {
    return HistorialEntryEntity(
      etapa: h['etapa'] as String,
      fecha: DateTime.parse(h['fecha'] as String),
      responsable: h['responsable'] as String,
    );
  }

  FichaCostoEntity _mapFicha(Map<String, dynamic> f) {
    return FichaCostoEntity(
      nombre: f['nombre'] as String,
      version: f['version'] as String,
      costoPorUnidad: (f['costoPorUnidad'] as num).toDouble(),
      costoTotal: (f['costoTotal'] as num).toDouble(),
      completado: f['completado'] as bool,
    );
  }

  // ignore: unused_element
  static dynamic _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return int.parse('FF$h', radix: 16);
  }
}
