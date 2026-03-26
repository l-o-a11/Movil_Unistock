import 'package:flutter/material.dart';

import '../../domain/entities/orden_entity.dart';
import '../../domain/entities/orden_detail_entity.dart';
import '../../domain/entities/orden_referencia_entity.dart';
import '../../domain/entities/historial_entry_entity.dart';
import '../../domain/entities/ficha_costo_entity.dart';

/// Modelo de datos del detalle de una orden. Extiende [OrdenDetailEntity]
/// y sabe cómo construirse desde JSON o desde los datos mock internos.
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

  // ── Mock fixtures ─────────────────────────────────────────────────────────

  static final Map<String, OrdenDetailModel> _mockDetails = {
    '1': OrdenDetailModel(
      id: '1',
      numero: 21,
      unidades: 300,
      estado: OrdenEstado.enProduccion,
      tipo: OrdenTipo.terceros,
      cliente: 'Sorelly santana rojo',
      fechaEntrega: DateTime(2025, 4, 11),
      refCorte: '513_3005',
      ref: '513',
      fechaEstado: DateTime(2025, 4, 11),
      progreso: 0.60,
      etapaActual: 2,
      referencias: const [
        OrdenReferenciaEntity(
            codigo: '3005',
            cantidad: 50,
            color: Color(0xFFE53935),
            colorName: 'Rojo'),
        OrdenReferenciaEntity(
            codigo: '542',
            cantidad: 50,
            color: Color(0xFFE53935),
            colorName: 'Rojo'),
        OrdenReferenciaEntity(
            codigo: '542',
            cantidad: 50,
            color: Color(0xFF212121),
            colorName: 'Negro'),
      ],
      historial: [
        HistorialEntryEntity(
            etapa: 'Diseño',
            fecha: DateTime(2025, 4, 11),
            responsable: 'Samanta Rosales'),
        HistorialEntryEntity(
            etapa: 'Ficha técnica',
            fecha: DateTime(2025, 4, 11),
            responsable: 'Samanta Rosales'),
        HistorialEntryEntity(
            etapa: 'Corte',
            fecha: DateTime(2025, 4, 11),
            responsable: 'Samanta Rosales'),
        HistorialEntryEntity(
            etapa: 'Compras',
            fecha: DateTime(2025, 4, 11),
            responsable: 'Samanta Rosales'),
        HistorialEntryEntity(
            etapa: 'Producción',
            fecha: DateTime(2025, 4, 11),
            responsable: 'Samanta Rosales'),
      ],
      fichaCosto: const FichaCostoEntity(
        nombre: 'Ficha técnica top aurora',
        version: 'Versión 1.0',
        costoPorUnidad: 48900,
        costoTotal: 2800900,
        completado: true,
      ),
    ),
    '2': OrdenDetailModel(
      id: '2',
      numero: 23,
      unidades: 50,
      estado: OrdenEstado.pendiente,
      tipo: OrdenTipo.terceros,
      cliente: 'Maria García López',
      fechaEntrega: DateTime(2025, 4, 15),
      refCorte: '520_1002',
      ref: '520',
      fechaEstado: DateTime(2025, 4, 12),
      progreso: 0.15,
      etapaActual: 0,
      referencias: const [
        OrdenReferenciaEntity(
            codigo: '1002',
            cantidad: 30,
            color: Color(0xFF1E88E5),
            colorName: 'Azul'),
        OrdenReferenciaEntity(
            codigo: '1003',
            cantidad: 20,
            color: Color(0xFFFFFFFF),
            colorName: 'Blanco'),
      ],
      historial: [
        HistorialEntryEntity(
            etapa: 'Diseño',
            fecha: DateTime(2025, 4, 12),
            responsable: 'Samanta Rosales'),
      ],
      fichaCosto: const FichaCostoEntity(
        nombre: 'Ficha técnica blusa lino',
        version: 'Versión 1.0',
        costoPorUnidad: 32000,
        costoTotal: 1600000,
        completado: false,
      ),
    ),
    '3': OrdenDetailModel(
      id: '3',
      numero: 24,
      unidades: 120,
      estado: OrdenEstado.enProduccion,
      tipo: OrdenTipo.produccion,
      cliente: 'Carlos Restrepo',
      fechaEntrega: DateTime(2025, 4, 20),
      refCorte: '530_2010',
      ref: '530',
      fechaEstado: DateTime(2025, 4, 13),
      progreso: 0.40,
      etapaActual: 1,
      referencias: const [
        OrdenReferenciaEntity(
            codigo: '2010',
            cantidad: 60,
            color: Color(0xFF43A047),
            colorName: 'Verde'),
        OrdenReferenciaEntity(
            codigo: '2011',
            cantidad: 60,
            color: Color(0xFFFFA726),
            colorName: 'Naranja'),
      ],
      historial: [
        HistorialEntryEntity(
            etapa: 'Diseño',
            fecha: DateTime(2025, 4, 13),
            responsable: 'Samanta Rosales'),
        HistorialEntryEntity(
            etapa: 'Ficha técnica',
            fecha: DateTime(2025, 4, 13),
            responsable: 'Samanta Rosales'),
      ],
      fichaCosto: null,
    ),
    '4': OrdenDetailModel(
      id: '4',
      numero: 25,
      unidades: 75,
      estado: OrdenEstado.pendiente,
      tipo: OrdenTipo.produccion,
      cliente: 'Ana Rodríguez',
      fechaEntrega: DateTime(2025, 4, 18),
      refCorte: '540_3005',
      ref: '540',
      fechaEstado: DateTime(2025, 4, 14),
      progreso: 0.05,
      etapaActual: 0,
      referencias: const [
        OrdenReferenciaEntity(
            codigo: '3005',
            cantidad: 75,
            color: Color(0xFFAB47BC),
            colorName: 'Morado'),
      ],
      historial: [],
      fichaCosto: null,
    ),
  };

  /// Retorna el detalle mockeado para el [id] dado, o null si no existe.
  static OrdenDetailModel? findById(String id) => _mockDetails[id];
}
