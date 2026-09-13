import 'orden_entity.dart';
import 'orden_referencia_entity.dart';
import 'historial_entry_entity.dart';
import 'ficha_costo_entity.dart';
import 'tercero_asignacion_entity.dart';

const kProductionStates = [
  'En espera',
  'Diseño',
  'Ficha Técnica',
  'Corte',
  'Compras',
  'Producción',
  'Empaque',
  'Enviado',
];

/// Etiquetas visibles del flujo. El backend conserva el estado técnico
/// `Enviado`, pero ese punto del proceso corresponde a la recepción física
/// de la orden, tal como se muestra también en el dashboard.
const kProductionStepLabels = [
  'En espera',
  'Diseño',
  'Ficha Técnica',
  'Corte',
  'Compras',
  'Producción',
  'Empaque',
  'Recepción',
];

class OrdenDetailEntity extends OrdenEntity {
  final List<OrdenReferenciaEntity> referencias;
  final List<HistorialEntryEntity> historial;
  final FichaCostoEntity? fichaCosto;
  final List<TerceroAsignacion> terceros;
  // Nombre del empleado asignado — solo disponible en el detalle (el id y
  // etapaConfirmada ya viven en OrdenEntity, ver comentario allá).
  final String? empleadoAsignadoNombre;

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
    super.producto,
    super.color,
    super.fechaEstado,
    super.sede,
    super.terceroNombre,
    super.empleadoAsignadoId,
    super.etapaConfirmada,
    required this.referencias,
    required this.historial,
    this.fichaCosto,
    this.terceros = const [],
    this.empleadoAsignadoNombre,
  });

  /// Progreso real calculado desde la posición del estado en el flujo
  /// (igual que el web: completedSteps / totalSteps).
  double get progreso {
    final idx = estadoIndex;
    if (idx < 0) return 0.0;
    return idx / (kProductionStates.length - 1);
  }

  int get progresoPercent => (progreso * 100).round();

  /// Índice 0-based del estado actual en kProductionStates.
  ///
  /// Algunas respuestas históricas ya traen `Recepción`/`Recepcion`, aunque
  /// el endpoint de producción use `Enviado`. Ambos representan el último
  /// paso real del flujo y deben pintar el mismo avance.
  int get estadoIndex {
    final lower = estado.toLowerCase();
    final estadoCanonico = switch (lower) {
      'recepción' || 'recepcion' => 'enviado',
      'ficha tecnica' => 'ficha técnica',
      'en producción' => 'producción',
      _ => lower,
    };
    return kProductionStates.indexWhere(
      (s) => s.toLowerCase() == estadoCanonico,
    );
  }

  /// Nombre de la etapa para la interfaz; no altera el estado técnico que se
  /// envía al backend al avanzar una orden.
  String get etapaLabel {
    final idx = estadoIndex;
    return idx >= 0 ? kProductionStepLabels[idx] : estado;
  }

  String get siguienteEtapaLabel {
    final next = estadoIndex + 1;
    return next < kProductionStates.length ? kProductionStates[next] : 'Finalizado';
  }

  bool get isAnulada => estado == 'Anulada';

  /// Nombre del siguiente estado del flujo, o null si la orden ya está en
  /// el último paso (o fue anulada). Se usa para habilitar el botón
  /// "Siguiente" — igual que `nextStep` en ProductionDetailsPage.jsx.
  String? get nextEstado {
    if (isAnulada) return null;
    final idx = estadoIndex;
    if (idx < 0) return null;
    final next = idx + 1;
    return next < kProductionStates.length ? kProductionStates[next] : null;
  }
}
