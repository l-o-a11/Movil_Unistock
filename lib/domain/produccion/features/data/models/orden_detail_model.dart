import 'package:flutter/material.dart';

import '../../domain/entities/orden_detail_entity.dart';
import '../../domain/entities/orden_referencia_entity.dart';
import '../../domain/entities/historial_entry_entity.dart';
import '../../domain/entities/ficha_costo_entity.dart';
import '../../domain/entities/tercero_asignacion_entity.dart';

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
    super.sede,
    super.terceroNombre,
    required super.referencias,
    required super.historial,
    super.fichaCosto,
    super.terceros,
    super.empleadoAsignadoId,
    super.empleadoAsignadoNombre,
    super.etapaConfirmada,
  });

  factory OrdenDetailModel.fromJson(Map<String, dynamic> json) {
    String? s(dynamic v) => v == null ? null : v.toString();

    final detalles = (json['detalles'] as List<dynamic>?) ?? [];

    // refCorte: primer id_producto de detalles
    final refCorte =
        s(json['refCorte']) ??
        (detalles.isNotEmpty ? s(detalles[0]['id_producto']) : null);

    // ref: campo ref / referencia (objeto o string) / producto
    String? ref;
    if (json['ref'] != null) {
      ref = s(json['ref']);
    } else if (json['referencia'] != null) {
      final r = json['referencia'];
      ref = r is Map
          ? (s(r['nombre']) ?? s(r['ref']) ?? s(r['codigo']))
          : s(r);
    }
    ref ??= s(json['producto']);

    // fechaEstado
    DateTime? fechaEstado;
    if (json['fechaEstado'] != null) {
      fechaEstado = DateTime.tryParse(json['fechaEstado'].toString());
    } else {
      final hist = (json['historial'] as List<dynamic>?) ?? [];
      if (hist.isNotEmpty) fechaEstado = DateTime.tryParse(s(hist.last['fecha']) ?? '');
      fechaEstado ??= DateTime.tryParse(s(json['updatedAt']) ?? s(json['updated_at']) ?? '');
    }

    // sede — puede venir en varios campos
    final sede = s(json['sede']) ?? s(json['sede_nombre']) ?? s(json['sedeNombre']);

    // referencias de color/talla
    final refsRaw = (json['referencias'] as List<dynamic>?);
    final referencias = refsRaw != null && refsRaw.isNotEmpty
        ? refsRaw.map((r) => OrdenReferenciaEntity(
              codigo: (r['codigo'] ?? r['ref'] ?? r['referencia'] ?? '').toString(),
              cantidad: ((r['cantidad'] ?? r['qty'] ?? 0) as num).toInt(),
              color: _parseColor((r['colorHex'] ?? r['colorHexCode'] ?? '#FF4FD6').toString()),
              colorName: (r['colorName'] ?? r['color'] ?? '').toString(),
            )).toList()
        : detalles.map((d) => OrdenReferenciaEntity(
              codigo: (d['id_producto'] ?? d['referencia'] ?? '').toString(),
              cantidad: ((d['cantidad'] ?? 0) as num).toInt(),
              color: _parseColor((d['colorHex'] ?? '#FF4FD6').toString()),
              colorName: (d['color'] ?? '').toString(),
            )).toList();

    // historial
    final historial = ((json['historial'] as List<dynamic>?) ?? [])
        .map((h) => HistorialEntryEntity(
              etapa: (h['etapa'] ?? h['estado'] ?? '').toString(),
              fecha: DateTime.tryParse((h['fecha'] ?? h['date'] ?? '').toString()) ?? DateTime.now(),
              responsable: (h['responsable'] ?? h['user'] ?? '').toString(),
            ))
        .toList();

    // ficha técnica
    final fichaRaw = json['fichaCosto'] ?? json['ficha_tecnica'] ?? json['fichaTecnica'] ?? json['ficha'];
    FichaCostoEntity? ficha;
    if (fichaRaw is Map) {
      final cpu = fichaRaw['costoPorUnidad'] ?? fichaRaw['costPerUnit'] ?? 0;
      final ct  = fichaRaw['costoTotal']     ?? fichaRaw['totalCost']   ?? 0;
      ficha = FichaCostoEntity(
        nombre: s(fichaRaw['nombre']) ?? 'Ficha técnica',
        version: s(fichaRaw['version']) ?? '',
        costoPorUnidad: cpu is num ? cpu.toDouble() : double.tryParse(cpu.toString()) ?? 0,
        costoTotal:     ct  is num ? ct.toDouble()  : double.tryParse(ct.toString())  ?? 0,
        completado: (fichaRaw['completado'] ?? fichaRaw['completed'] ?? false) as bool,
      );
    }

    // terceros asignados
    final tercerosRaw =
        (json['terceros'] as List<dynamic>?) ??
        (json['asignaciones'] as List<dynamic>?) ?? [];
    final terceros = tercerosRaw
        .whereType<Map>()
        .map((t) => TerceroAsignacion.fromJson(Map<String, dynamic>.from(t)))
        .toList();

    // nombre del primer tercero para el resumen rápido
    final terceroNombre = terceros.isNotEmpty ? terceros.first.nombre : null;

    // campos numéricos
    final numero    = json['numero_orden'] ?? json['numero'] ?? 0;
    final uRaw      = json['unidades'] ?? detalles.fold<int>(0, (a, d) => a + ((d['cantidad'] ?? 0) as num).toInt());
    final unidades  = uRaw is num ? uRaw.toInt() : int.tryParse(uRaw.toString()) ?? 0;

    // fechaEntrega
    final fe = json['fechaEntrega'] ?? json['fecha_entrega'];
    final fechaEntrega = fe != null ? DateTime.tryParse(fe.toString()) : null;

    // Asignación/confirmación de etapa por parte del empleado — igual
    // mapeo que toFrontendFormat() en ProductionAPIClient.js del web.
    final empleadoAsignaciones = json['empleadoAsignaciones'];
    final empleadoAsignadoId = s(json['empleadoAsignadoId']) ??
        (empleadoAsignaciones is Map
            ? s((empleadoAsignaciones[json['estado']] as Map?)?['id_empleado'])
            : null);
    final empleadoAsignadoNombre = s(json['empleadoAsignadoNombre']) ??
        (empleadoAsignaciones is Map
            ? s((empleadoAsignaciones[json['estado']] as Map?)?['nombre_empleado'])
            : null);
    final etapaConfirmada = json['etapaConfirmada'] == true;

    return OrdenDetailModel(
      id:            (json['_id'] ?? json['id'] ?? '').toString(),
      numero:        numero is num ? numero.toInt() : int.tryParse(numero.toString()) ?? 0,
      unidades:      unidades,
      estado:        (json['estado'] ?? '').toString(),
      tipo:          (json['tipo'] ?? 'produccion').toString().toLowerCase(),
      cliente:       s(json['cliente'] ?? json['client']),
      fechaEntrega:  fechaEntrega,
      refCorte:      refCorte,
      ref:           ref,
      fechaEstado:   fechaEstado,
      sede:          sede,
      terceroNombre: terceroNombre,
      referencias:   referencias,
      historial:     historial,
      fichaCosto:    ficha,
      terceros:      terceros,
      empleadoAsignadoId:     empleadoAsignadoId,
      empleadoAsignadoNombre: empleadoAsignadoNombre,
      etapaConfirmada:        etapaConfirmada,
    );
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '').padLeft(6, '0');
    try { return Color(int.parse('FF$h', radix: 16)); } catch (_) { return const Color(0xFFFF4FD6); }
  }
}
