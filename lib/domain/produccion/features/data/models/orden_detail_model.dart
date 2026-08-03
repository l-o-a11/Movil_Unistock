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

  /// Parseo DEFENSIVO: si `detalles`, `historial`, `referencias` o
  /// `terceros` llegan como un tipo distinto a List (o con items no-Map),
  /// se omiten en lugar de lanzar excepción. Esto evita que un payload
  /// válido del backend dispare el fallback a datos mock.
  factory OrdenDetailModel.fromJson(Map<String, dynamic> json) {
    String? s(dynamic v) => v == null ? null : v.toString();

    // ── Detalles ────────────────────────────────────────────────────────
    final detallesRaw = json['detalles'];
    final detalles = detallesRaw is List
        ? detallesRaw.whereType<Map>().toList()
        : const <Map>[];

    // refCorte: primer id_producto de detalles
    final refCorte =
        s(json['refCorte']) ??
        (detalles.isNotEmpty ? s(detalles.first['id_producto']) : null);

    // ref: campo ref / referencia (objeto o string) / producto
    String? ref;
    if (json['ref'] != null) {
      ref = s(json['ref']);
    } else if (json['referencia'] != null) {
      final r = json['referencia'];
      ref = r is Map ? (s(r['nombre']) ?? s(r['ref']) ?? s(r['codigo'])) : s(r);
    }
    ref ??= s(json['producto']);

    // fechaEstado
    DateTime? fechaEstado;
    if (json['fechaEstado'] != null) {
      fechaEstado = DateTime.tryParse(json['fechaEstado'].toString());
    } else {
      final histRaw = json['historial'];
      final hist = histRaw is List ? histRaw : const <dynamic>[];
      if (hist.isNotEmpty && hist.last is Map) {
        fechaEstado = DateTime.tryParse(s(hist.last['fecha']) ?? '');
      }
      fechaEstado ??= DateTime.tryParse(
        s(json['updatedAt']) ?? s(json['updated_at']) ?? '',
      );
    }

    // sede — puede venir en varios campos
    final sede =
        s(json['sede']) ?? s(json['sede_nombre']) ?? s(json['sedeNombre']);

    // referencias de color/talla
    final refsRaw = json['referencias'];
    final refsList = refsRaw is List
        ? refsRaw.whereType<Map>().toList()
        : <Map>[];

    final referencias = refsList.isNotEmpty
        ? refsList
              .map(
                (r) => OrdenReferenciaEntity(
                  codigo: (r['codigo'] ?? r['ref'] ?? r['referencia'] ?? '')
                      .toString(),
                  cantidad: ((r['cantidad'] ?? r['qty'] ?? 0) as num).toInt(),
                  color: _parseColor(
                    (r['colorHex'] ?? r['colorHexCode'] ?? '#FF4FD6')
                        .toString(),
                  ),
                  colorName: (r['colorName'] ?? r['color'] ?? '').toString(),
                ),
              )
              .toList()
        : detalles
              .map(
                (d) => OrdenReferenciaEntity(
                  codigo: (d['id_producto'] ?? d['referencia'] ?? '')
                      .toString(),
                  cantidad: ((d['cantidad'] ?? 0) as num).toInt(),
                  color: _parseColor((d['colorHex'] ?? '#FF4FD6').toString()),
                  colorName: (d['color'] ?? '').toString(),
                ),
              )
              .toList();

    // historial
    final historialRaw = json['historial'];
    final historialList = historialRaw is List
        ? historialRaw.whereType<Map>().toList()
        : <Map>[];
    final historial = historialList
        .map(
          (h) => HistorialEntryEntity(
            etapa: (h['etapa'] ?? h['estado'] ?? '').toString(),
            fecha:
                DateTime.tryParse((h['fecha'] ?? h['date'] ?? '').toString()) ??
                DateTime.now(),
            responsable: (h['responsable'] ?? h['user'] ?? '').toString(),
          ),
        )
        .toList();

    // ficha técnica
    final fichaRaw =
        json['fichaCosto'] ??
        json['ficha_tecnica'] ??
        json['fichaTecnica'] ??
        json['ficha'];
    FichaCostoEntity? ficha;
    if (fichaRaw is Map) {
      final cpu = fichaRaw['costoPorUnidad'] ?? fichaRaw['costPerUnit'] ?? 0;
      final ct = fichaRaw['costoTotal'] ?? fichaRaw['totalCost'] ?? 0;
      ficha = FichaCostoEntity(
        nombre: s(fichaRaw['nombre']) ?? 'Ficha técnica',
        version: s(fichaRaw['version']) ?? '',
        costoPorUnidad: cpu is num
            ? cpu.toDouble()
            : double.tryParse(cpu.toString()) ?? 0,
        costoTotal: ct is num
            ? ct.toDouble()
            : double.tryParse(ct.toString()) ?? 0,
        completado:
            (fichaRaw['completado'] ?? fichaRaw['completed'] ?? false) as bool,
      );
    }

    // terceros asignados
    final tercerosRaw = json['terceros'] ?? json['asignaciones'];
    final tercerosList = tercerosRaw is List
        ? tercerosRaw.whereType<Map>().toList()
        : <Map>[];
    final terceros = tercerosList
        .map((t) => TerceroAsignacion.fromJson(Map<String, dynamic>.from(t)))
        .toList();

    // nombre del primer tercero para el resumen rápido
    final terceroNombre = terceros.isNotEmpty ? terceros.first.nombre : null;

    // campos numéricos
    final numero = json['numero_orden'] ?? json['numero'] ?? 0;
    final uRaw =
        json['unidades'] ??
        detalles.fold<int>(0, (a, d) {
          final cant = d['cantidad'] ?? 0;
          return a +
              (cant is num ? cant.toInt() : int.tryParse(cant.toString()) ?? 0);
        });
    final unidades = uRaw is num
        ? uRaw.toInt()
        : int.tryParse(uRaw.toString()) ?? 0;

    // fechaEntrega
    final fe = json['fechaEntrega'] ?? json['fecha_entrega'];
    final fechaEntrega = fe != null ? DateTime.tryParse(fe.toString()) : null;

    // Asignación/confirmación de etapa por parte del empleado — igual
    // mapeo que toFrontendFormat() en ProductionAPIClient.js del web.
    final empleadoAsignaciones = json['empleadoAsignaciones'];
    final empleadoAsignadoId =
        s(json['empleadoAsignadoId']) ??
        (empleadoAsignaciones is Map
            ? s((empleadoAsignaciones[json['estado']] as Map?)?['id_empleado'])
            : null);
    final empleadoAsignadoNombre =
        s(json['empleadoAsignadoNombre']) ??
        (empleadoAsignaciones is Map
            ? s(
                (empleadoAsignaciones[json['estado']]
                    as Map?)?['nombre_empleado'],
              )
            : null);
    final etapaConfirmada = json['etapaConfirmada'] == true;

    return OrdenDetailModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      numero: numero is num
          ? numero.toInt()
          : int.tryParse(numero.toString()) ?? 0,
      unidades: unidades,
      estado: (json['estado'] ?? '').toString(),
      tipo: (json['tipo'] ?? 'produccion').toString().toLowerCase(),
      cliente: s(json['cliente'] ?? json['client']),
      fechaEntrega: fechaEntrega,
      refCorte: refCorte,
      ref: ref,
      fechaEstado: fechaEstado,
      sede: sede,
      terceroNombre: terceroNombre,
      referencias: referencias,
      historial: historial,
      fichaCosto: ficha,
      terceros: terceros,
      empleadoAsignadoId: empleadoAsignadoId,
      empleadoAsignadoNombre: empleadoAsignadoNombre,
      etapaConfirmada: etapaConfirmada,
    );
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '').padLeft(6, '0');
    try {
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFFFF4FD6);
    }
  }
}
