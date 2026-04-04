import '../../domain/entities/orden_entity.dart';

enum ProduccionTab { produccion, terceros }

class ProduccionState {
  final bool isLoading;
  final String? error;
  final List<OrdenEntity> ordenes;
  final OrdenEstado? filtroEstado;
  final OrdenTipo? filtroTipo;
  final String searchQuery;
  final ProduccionTab activeTab;
  final Set<String> expandedIds;

  const ProduccionState({
    this.isLoading = false,
    this.error,
    this.ordenes = const [],
    this.filtroEstado,
    this.filtroTipo,
    this.searchQuery = '',
    this.activeTab = ProduccionTab.produccion,
    this.expandedIds = const {},
  });

  bool get hasError => error != null;
  bool get isLoaded => !isLoading && error == null;
  bool isExpanded(String id) => expandedIds.contains(id);

  ProduccionState copyWith({
    bool? isLoading,
    String? error,
    List<OrdenEntity>? ordenes,
    OrdenEstado? filtroEstado,
    bool clearFiltroEstado = false,
    OrdenTipo? filtroTipo,
    bool clearFiltroTipo = false,
    String? searchQuery,
    ProduccionTab? activeTab,
    Set<String>? expandedIds,
  }) {
    return ProduccionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      ordenes: ordenes ?? this.ordenes,
      filtroEstado: clearFiltroEstado ? null : (filtroEstado ?? this.filtroEstado),
      filtroTipo: clearFiltroTipo ? null : (filtroTipo ?? this.filtroTipo),
      searchQuery: searchQuery ?? this.searchQuery,
      activeTab: activeTab ?? this.activeTab,
      expandedIds: expandedIds ?? this.expandedIds,
    );
  }
}
