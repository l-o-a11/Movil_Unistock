import 'package:flutter/material.dart';
import '../../domain/entities/orden_entity.dart';
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

  Future<void> loadOrdenes() async {
    _emit(_state.copyWith(isLoading: true));
    try {
      final ordenes = await getOrdenesUseCase(
        estado: _state.filtroEstado,
        tipo: _state.activeTab == ProduccionTab.terceros
            ? OrdenTipo.terceros
            : OrdenTipo.produccion,
        query: _state.searchQuery.isEmpty ? null : _state.searchQuery,
      );
      _emit(_state.copyWith(isLoading: false, ordenes: ordenes));
    } catch (e) {
      _emit(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void setFiltroEstado(OrdenEstado? estado) {
    if (estado == null) {
      _emit(_state.copyWith(clearFiltroEstado: true));
    } else {
      _emit(_state.copyWith(filtroEstado: estado));
    }
    loadOrdenes();
  }

  void setSearch(String q) {
    _emit(_state.copyWith(searchQuery: q));
    loadOrdenes();
  }

  void changeTab(ProduccionTab tab) {
    _emit(_state.copyWith(activeTab: tab, expandedIds: {}));
    loadOrdenes();
  }

  void toggleExpanded(String id) {
    // Solo una tarjeta abierta a la vez
    final isOpen = _state.expandedIds.contains(id);
    final newSet = isOpen ? <String>{} : <String>{id};
    _emit(_state.copyWith(expandedIds: newSet));
  }
}
