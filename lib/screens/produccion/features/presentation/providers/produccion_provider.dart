import 'package:flutter/material.dart';

import '../../domain/entities/orden_entity.dart';
import '../../domain/usecases/get_ordenes_usecase.dart';
import '../state/produccion_state.dart';

class ProduccionProvider extends ChangeNotifier {
  final GetOrdenesUseCase getOrdenesUseCase;

  ProduccionState _state = const ProduccionState();
  ProduccionState get state => _state;

  ProduccionProvider({required this.getOrdenesUseCase}) {
    loadOrdenes();
  }

  Future<void> loadOrdenes() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final tipo = _state.activeTab == ProduccionTab.terceros
          ? OrdenTipo.terceros
          : OrdenTipo.produccion;

      final ordenes = await getOrdenesUseCase(
        estado: _state.filtroEstado,
        tipo: tipo,
        query: _state.searchQuery.isNotEmpty ? _state.searchQuery : null,
      );

      _state = _state.copyWith(ordenes: ordenes, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Error al cargar órdenes: $e',
      );
    }

    notifyListeners();
  }

  void changeTab(ProduccionTab tab) {
    _state = _state.copyWith(activeTab: tab);
    notifyListeners();
    loadOrdenes();
  }

  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
    loadOrdenes();
  }

  void updateFiltroEstado(OrdenEstado? estado) {
    if (estado == null) {
      _state = _state.copyWith(clearFiltroEstado: true);
    } else {
      _state = _state.copyWith(filtroEstado: estado);
    }
    notifyListeners();
    loadOrdenes();
  }

  void toggleExpanded(String id) {
    final newSet = Set<String>.from(_state.expandedIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    _state = _state.copyWith(expandedIds: newSet);
    notifyListeners();
  }
}
