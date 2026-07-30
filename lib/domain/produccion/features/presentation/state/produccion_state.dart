import '../../domain/entities/orden_entity.dart';

enum ProduccionTab { produccion, terceros }

class ProduccionState {
  final bool isLoading;
  final String? error;
  final List<OrdenEntity> ordenes;
  final String? filtroEstado;   // String exacto: "Producción", "Corte", etc.
  final String searchQuery;
  final ProduccionTab activeTab;
  final Set<String> expandedIds;
  // ── Rol / usuario logueado — ver AuthService.getRolNombre/getUserId ────
  final String rolNombre;
  final String? userId;

  const ProduccionState({
    this.isLoading = false,
    this.error,
    this.ordenes = const [],
    this.filtroEstado,
    this.searchQuery = '',
    this.activeTab = ProduccionTab.produccion,
    this.expandedIds = const {},
    this.rolNombre = '',
    this.userId,
  });

  bool get hasError => error != null;
  bool get isLoaded => !isLoading && error == null;
  bool isExpanded(String id) => expandedIds.contains(id);

  bool get isGerente => rolNombre == 'gerente';
  bool get isAdministrador => rolNombre == 'administrador';
  bool get isEmpleado => rolNombre == 'empleado';

  /// Órdenes filtradas igual que el web:
  /// - Por defecto oculta Anulada y Enviado (HIDDEN_STATUSES)
  /// - Si hay filtroEstado activo, muestra todas las que coincidan
  /// - Tab produccion: tipo != terceros; Tab terceros: tipo == terceros
  /// - Alcance de visibilidad ("matchesSede" en ProductionPage.jsx):
  ///   Gerente y Administrador ven TODAS las órdenes. Cualquier otro rol
  ///   (Empleado) solo ve la orden si ÉL es el empleado asignado a la
  ///   etapa actual y esa etapa aún NO fue confirmada — una vez que
  ///   confirma, la orden desaparece de su lista.
  List<OrdenEntity> get ordenesFiltradas {
    final term = searchQuery.toLowerCase();
    return ordenes.where((o) {
      // Tab filter
      if (activeTab == ProduccionTab.terceros && !o.isTerceros) return false;
      if (activeTab == ProduccionTab.produccion && o.isTerceros) return false;

      // HIDDEN_STATUSES: igual que el web
      if (filtroEstado == null && o.isHidden) return false;

      // Estado filter
      if (filtroEstado != null && o.estado != filtroEstado) return false;

      // Alcance por rol
      if (!isGerente && !isAdministrador) {
        final esMiOrden = userId != null &&
            o.empleadoAsignadoId != null &&
            o.empleadoAsignadoId == userId;
        if (!esMiOrden || o.etapaConfirmada) return false;
      }

      // Search
      if (term.isNotEmpty) {
        final fields = [
          o.cliente, o.estado, o.producto, o.ref, o.refCorte,
          o.color, '${o.numero}', '${o.unidades}',
        ];
        return fields.any((f) => (f ?? '').toLowerCase().contains(term));
      }
      return true;
    }).toList();
  }

  ProduccionState copyWith({
    bool? isLoading,
    String? error,
    List<OrdenEntity>? ordenes,
    String? filtroEstado,
    bool clearFiltroEstado = false,
    String? searchQuery,
    ProduccionTab? activeTab,
    Set<String>? expandedIds,
    String? rolNombre,
    String? userId,
  }) {
    return ProduccionState(
      isLoading:    isLoading    ?? this.isLoading,
      error:        error,
      ordenes:      ordenes      ?? this.ordenes,
      filtroEstado: clearFiltroEstado ? null : (filtroEstado ?? this.filtroEstado),
      searchQuery:  searchQuery  ?? this.searchQuery,
      activeTab:    activeTab    ?? this.activeTab,
      expandedIds:  expandedIds  ?? this.expandedIds,
      rolNombre:    rolNombre    ?? this.rolNombre,
      userId:       userId       ?? this.userId,
    );
  }
}
