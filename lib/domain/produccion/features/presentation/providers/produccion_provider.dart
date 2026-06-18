import 'package:flutter/material.dart';
import '../../domain/usecases/get_ordenes_usecase.dart';
import '../state/produccion_state.dart';

class ProduccionProvider extends ChangeNotifier {
  final GetOrdenesUseCase getOrdenesUseCase;

  ProduccionProvider({required this.getOrdenesUseCase}) {
    loadOrdenes();
  }

  ProduccionState _state = const ProduccionState();
  ProduccionState get state => _state;

  void _emit(ProduccionState s) {
    _state = s;
    notifyListeners();
  }

  /// Carga TODAS las órdenes sin filtrar (igual que el web).
  /// El filtrado se hace localmente en [ProduccionState.ordenesFiltradas].
  Future<void> loadOrdenes() async {
    _emit(_state.copyWith(isLoading: true));
    try {
      // Sin pasar estado ni tipo: traer todo y filtrar en cliente
      final ordenes = await getOrdenesUseCase(
        query: _state.searchQuery.isEmpty ? null : _state.searchQuery,
      );
      _emit(_state.copyWith(isLoading: false, ordenes: ordenes));
    } catch (e) {
      _emit(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Filtrar por estado (String exacto del backend)
  void setFiltroEstado(String? estado) {
    _emit(_state.copyWith(
      filtroEstado: estado,
      clearFiltroEstado: estado == null,
    ));
    // No rellamamos API — el filtro es local
    notifyListeners();
  }

  void setSearch(String q) {
    _emit(_state.copyWith(searchQuery: q));
    loadOrdenes();
  }

  void changeTab(ProduccionTab tab) {
    _emit(_state.copyWith(activeTab: tab, expandedIds: {}));
    notifyListeners();
  }

  void toggleExpanded(String id) {
    final isOpen = _state.expandedIds.contains(id);
    final newSet = isOpen ? <String>{} : <String>{id};
    _emit(_state.copyWith(expandedIds: newSet));
  }

  /// Estados únicos disponibles para los chips de filtro
  List<String> get estadosDisponibles {
    final all = _state.ordenes.map((o) => o.estado).toSet().toList();
    all.sort();
    return all;
  }
}
