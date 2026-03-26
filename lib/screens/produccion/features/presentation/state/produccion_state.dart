import '../../domain/entities/orden_entity.dart';

enum ProduccionTab { producciones, terceros }

class ProduccionState {
  final List<OrdenEntity> ordenes;
  final bool isLoading;
  final String? error;
  final ProduccionTab activeTab;
  final OrdenEstado? filtroEstado;
  final String searchQuery;
  final Set<String> expandedIds;

  const ProduccionState({
    this.ordenes = const [],
    this.isLoading = false,
    this.error,
    this.activeTab = ProduccionTab.producciones,
    this.filtroEstado,
    this.searchQuery = '',
    this.expandedIds = const {},
  });

  ProduccionState copyWith({
    List<OrdenEntity>? ordenes,
    bool? isLoading,
    String? error,
    ProduccionTab? activeTab,
    OrdenEstado? filtroEstado,
    bool clearFiltroEstado = false,
    String? searchQuery,
    Set<String>? expandedIds,
  }) {
    return ProduccionState(
      ordenes: ordenes ?? this.ordenes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeTab: activeTab ?? this.activeTab,
      filtroEstado:
          clearFiltroEstado ? null : (filtroEstado ?? this.filtroEstado),
      searchQuery: searchQuery ?? this.searchQuery,
      expandedIds: expandedIds ?? this.expandedIds,
    );
  }

  bool isExpanded(String id) => expandedIds.contains(id);
}
