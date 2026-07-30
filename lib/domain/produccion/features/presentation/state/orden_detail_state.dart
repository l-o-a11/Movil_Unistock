import '../../domain/entities/orden_detail_entity.dart';

/// Estado del detalle de una orden.
///
/// Propiedades:
/// - [isLoading]: indica carga en progreso
/// - [error]: mensaje de error (null si no hay error)
/// - [detail]: detalle completo de la orden (null si no cargado)
class OrdenDetailState {
  final bool isLoading;
  final String? error;
  final OrdenDetailEntity? detail;
  // ── Rol del usuario logueado (ver AuthService.getRolNombre) ───────────
  final String rolNombre;
  // ── Acción en curso: avanzar estado / confirmar etapa ──────────────────
  final bool isActionLoading;
  final String? actionError;

  const OrdenDetailState({
    this.isLoading = false,
    this.error,
    this.detail,
    this.rolNombre = '',
    this.isActionLoading = false,
    this.actionError,
  });

  bool get hasError => error != null;
  bool get isLoaded => !isLoading && error == null && detail != null;

  bool get isGerente => rolNombre == 'gerente';
  bool get isAdministrador => rolNombre == 'administrador';
  bool get isEmpleado => rolNombre == 'empleado';

  OrdenDetailState copyWith({
    bool? isLoading,
    String? error,
    OrdenDetailEntity? detail,
    String? rolNombre,
    bool? isActionLoading,
    String? actionError,
    bool clearActionError = false,
  }) {
    return OrdenDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      detail: detail ?? this.detail,
      rolNombre: rolNombre ?? this.rolNombre,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }
}
