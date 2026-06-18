import 'package:flutter/material.dart';

import '../../domain/entities/orden_detail_entity.dart';
import '../../domain/entities/orden_referencia_entity.dart';
import '../../domain/entities/historial_entry_entity.dart';
import '../../domain/entities/ficha_costo_entity.dart';

/// Modelo de datos del detalle de una orden. Extiende [OrdenDetailEntity]
/// y sabe cómo construirse desde JSON.
class OrdenDetailModel extends OrdenDetailEntity {
  const OrdenDetailModel({
    required super.id,
    required super.numero,
    required super.unidades,
    required super.estado,
    required super.tipo,
    super.cliente,
    super.fechaEntrega,
    super.refCorte,
    super.ref,
    super.fechaEstado,
    required super.progreso,
    required super.etapaActual,
    required super.referencias,
    required super.historial,
    super.fichaCosto,
  });

  factory OrdenDetailModel.fromJson(Map<String, dynamic> json) {
    return OrdenDetailModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      numero: ((json['numero_orden'] ?? json['numero'] ?? 0) as num).toInt(),
      unidades: ((json['unidades'] ?? 0) as num).toInt(),
      estado: (json['estado'] ?? '').toString(),
      tipo: (json['tipo'] ?? 'produccion').toString().toLowerCase(),
      cliente: json['cliente']?.toString(),
      fechaEntrega: json['fechaEntrega'] != null ? DateTime.tryParse(json['fechaEntrega'].toString()) : null,
      refCorte: json['refCorte']?.toString(),
      ref: json['ref']?.toString(),
      fechaEstado: json['fechaEstado'] != null
          ? DateTime.tryParse(json['fechaEstado'])
          : null,
      progreso: (json['progreso'] as num).toDouble(),
      etapaActual: json['etapaActual'] as int,
      referencias: (json['referencias'] as List<dynamic>?)
              ?.map((r) => OrdenReferenciaEntity(
                  codigo: r['codigo'] as String,
                  cantidad: r['cantidad'] as int,
                  color: _parseColor(r['colorHex'] as String? ?? '#000000'),
                  colorName: r['colorName'] as String,
                ))
              .toList() ?? [],
      historial: (json['historial'] as List<dynamic>?)
              ?.map((h) => HistorialEntryEntity(
                  etapa: h['etapa'] as String,
                  fecha: DateTime.parse(h['fecha'] as String),
                  responsable: h['responsable'] as String,
                ))
              .toList() ?? [],
      fichaCosto: json['fichaCosto'] != null
          ? FichaCostoEntity(
              nombre: json['fichaCosto']['nombre'] as String,
              version: json['fichaCosto']['version'] as String,
              costoPorUnidad: (json['fichaCosto']['costoPorUnidad'] as num).toDouble(),
              costoTotal: (json['fichaCosto']['costoTotal'] as num).toDouble(),
              completado: json['fichaCosto']['completado'] as bool,
            )
          : null,
    );
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}