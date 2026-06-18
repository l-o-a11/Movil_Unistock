import 'orden_entity.dart';
import 'orden_referencia_entity.dart';
import 'historial_entry_entity.dart';
import 'ficha_costo_entity.dart';

class OrdenDetailEntity extends OrdenEntity {
  final double progreso;
  final int etapaActual;
  final List<OrdenReferenciaEntity> referencias;
  final List<HistorialEntryEntity> historial;
  final FichaCostoEntity? fichaCosto;

  const OrdenDetailEntity({
    required super.id,
    required super.numero,
    required super.unidades,
    required super.estado,   // String exacto del backend
    required super.tipo,     // String: "produccion" | "terceros"
    super.cliente,
    super.fechaEntrega,
    super.refCorte,
    super.ref,
    super.producto,
    super.color,
    super.fechaEstado,
    required this.progreso,
    required this.etapaActual,
    required this.referencias,
    required this.historial,
    this.fichaCosto,
  });

  int get progresoPercent => (progreso * 100).round();

  String get siguienteEtapaLabel {
    const etapas = ['Diseño', 'Ficha Técnica', 'Corte', 'Producción', 'Recepción'];
    final next = etapaActual + 1;
    return next < etapas.length ? etapas[next] : 'Finalizado';
  }
}
