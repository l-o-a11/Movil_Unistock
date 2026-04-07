import 'package:flutter/material.dart';
import '../../domain/entities/orden_entity.dart';
import '../../domain/usecases/get_ordenes_usecase.dart';
import '../state/produccion_state.dart';

/// Proveedor de estado para la lista de órdenes.
///
/// Gestiona:
/// - Carga de órdenes desde [GetOrdenesUseCase]
/// - Filtros por estado y tipo
/// - Búsqueda de texto
/// - Alternancia de tabs (Producciones/Terceros)
/// - Expansión de tarjetas individuales
///
/// Emite estado a través de [ProduccionState].
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

  /// Carga la lista de órdenes con filtros actuales.
  /// Dispara emisor de emisiones de estado durante la carga.
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

  /// Actualiza el filtro por estado y recarga las órdenes.
  /// Si [estado] es null, limpia el filtro.
  void setFiltroEstado(OrdenEstado? estado) {
    if (estado == null) {
      _emit(_state.copyWith(clearFiltroEstado: true));
    } else {
      _emit(_state.copyWith(filtroEstado: estado));
    }
    loadOrdenes();
  }

  /// Actualiza la consulta de búsqueda y recarga las órdenes.
  void setSearch(String q) {
    _emit(_state.copyWith(searchQuery: q));
    loadOrdenes();
  }

  /// Cambia el tab activo (Producciones o Terceros) y recarga.
  void changeTab(ProduccionTab tab) {
    _emit(_state.copyWith(activeTab: tab, expandedIds: {}));
    loadOrdenes();
  }

  /// Alterna la expansión de una tarjeta de orden.
  /// Sólo una tarjeta se puede expandir a la vez.
  void toggleExpanded(String id) {
    // Solo una tarjeta abierta a la vez
    final isOpen = _state.expandedIds.contains(id);
    final newSet = isOpen ? <String>{} : <String>{id};
    _emit(_state.copyWith(expandedIds: newSet));
  }
}
