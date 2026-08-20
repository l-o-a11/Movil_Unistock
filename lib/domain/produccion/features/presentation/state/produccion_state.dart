import '../../../../auth/domain/role_constants.dart';
import '../../domain/entities/orden_entity.dart';

enum ProduccionTab { produccion, terceros }

const int kOrdenesPageSize = 5;

class ProduccionState {
  final bool isLoading;
  final String? error;
  final List<OrdenEntity> ordenes;
  final String? filtroEstado;
  final ProduccionTab activeTab;
  final Set<String> expandedIds;
  final int visibleCount;
  final String rolNombre;
  final String? userId;
  final String? searchQuery;

  const ProduccionState({
    this.isLoading = false,
    this.error,
    this.ordenes = const [],
    this.filtroEstado,
    this.activeTab = ProduccionTab.produccion,
    this.expandedIds = const {},
    this.visibleCount = kOrdenesPageSize,
    this.rolNombre = '',
    this.userId,
    this.searchQuery,
  });

  bool get hasError => error != null;
  bool get isLoaded => !isLoading && error == null;
  bool isExpanded(String id) => expandedIds.contains(id);

  bool get isGerente => esGerente(rolNombre);
  bool get isAdministrador => esAdministrador(rolNombre);
  bool get isEmpleado => esEmpleado(rolNombre);

  List<OrdenEntity> get ordenesFiltradas {
    final query = searchQuery?.trim().toLowerCase();
    return ordenes.where((o) {
      if (activeTab == ProduccionTab.terceros && !o.isTerceros) return false;
      if (activeTab == ProduccionTab.produccion && o.isTerceros) return false;

      if (filtroEstado == null && o.isHidden) return false;
      if (filtroEstado != null && o.estado != filtroEstado) return false;

      if (!isGerente && !isAdministrador) {
        final esMiOrden =
            userId != null &&
            o.empleadoAsignadoId != null &&
            o.empleadoAsignadoId == userId;
        if (!esMiOrden || o.etapaConfirmada) return false;
      }

      if (query != null && query.isNotEmpty) {
        final campos = [
          o.numero.toString(),
          o.cliente ?? '',
          o.refCorte ?? '',
          o.ref ?? '',
          o.producto ?? '',
          o.color ?? '',
          o.sede ?? '',
          o.terceroNombre ?? '',
          o.estado,
          o.tipo,
        ].map((s) => s.toLowerCase());
        if (!campos.any((c) => c.contains(query))) return false;
      }

      return true;
    }).toList();
  }

  List<OrdenEntity> get ordenesVisibles =>
      ordenesFiltradas.take(visibleCount).toList();

  bool get hasMore => visibleCount < ordenesFiltradas.length;

  ProduccionState copyWith({
    bool? isLoading,
    String? error,
    List<OrdenEntity>? ordenes,
    String? filtroEstado,
    bool clearFiltroEstado = false,
    ProduccionTab? activeTab,
    Set<String>? expandedIds,
    int? visibleCount,
    String? rolNombre,
    String? userId,
    String? searchQuery,
  }) {
    return ProduccionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      ordenes: ordenes ?? this.ordenes,
      filtroEstado: clearFiltroEstado
          ? null
          : (filtroEstado ?? this.filtroEstado),
      activeTab: activeTab ?? this.activeTab,
      expandedIds: expandedIds ?? this.expandedIds,
      visibleCount: visibleCount ?? this.visibleCount,
      rolNombre: rolNombre ?? this.rolNombre,
      userId: userId ?? this.userId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
