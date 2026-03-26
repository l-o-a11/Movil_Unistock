import 'orden_entity.dart';
import 'orden_referencia_entity.dart';
import 'historial_entry_entity.dart';
import 'ficha_costo_entity.dart';

/// Detalle completo de una orden: extiende [OrdenEntity] con datos de progreso,
/// etapas, referencias, historial y ficha técnica.
class OrdenDetailEntity extends OrdenEntity {
  /// Valor entre 0.0 y 1.0 que representa el avance general.
  final double progreso;

  /// Índice (0-based) de la etapa actualmente activa en el flujo de producción.
  final int etapaActual;

  /// Referencias de talla/color incluidas en la orden.
  final List<OrdenReferenciaEntity> referencias;

  /// Historial cronológico de cambios de estado.
  final List<HistorialEntryEntity> historial;

  /// Ficha técnica y costos asociada, puede ser nula.
  final FichaCostoEntity? fichaCosto;

  const OrdenDetailEntity({
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
    required this.progreso,
    required this.etapaActual,
    required this.referencias,
    required this.historial,
    this.fichaCosto,
  });

  /// Porcentaje entero para mostrar en UI.
  int get progresoPercent => (progreso * 100).round();

  /// Nombre de la etapa siguiente (para el label "Siguiente etapa").
  String get siguienteEtapaLabel {
    const etapas = ['Diseño', 'Fecha Técnica', 'Corte', 'Producción', 'Recepción'];
    final next = etapaActual + 1;
    return next < etapas.length ? etapas[next] : 'Finalizado';
  }
}
