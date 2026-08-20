import 'package:flutter/material.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';
import '../../domain/usecases/get_ordenes_usecase.dart';
import '../state/produccion_state.dart';

class ProduccionProvider extends ChangeNotifier {
  final GetOrdenesUseCase getOrdenesUseCase;
  final AuthService _auth;
  bool _disposed = false;

  ProduccionProvider({required this.getOrdenesUseCase, AuthService? auth})
    : _auth = auth ?? AuthService() {
    loadOrdenes();
  }

  ProduccionState _state = const ProduccionState();
  ProduccionState get state => _state;

  void _emit(ProduccionState s) {
    if (_disposed) return;
    _state = s;
    notifyListeners();
  }

  Future<void> loadOrdenes() async {
    _emit(_state.copyWith(isLoading: true));
    try {
      final rolNombre = await _auth.getRolNombre();
      final userId = await _auth.getUserId();
      // Sin pasar estado ni tipo: traer todo y filtrar en cliente
      final ordenes = await getOrdenesUseCase(
         query: _state.searchQuery?.isEmpty ?? true ? null : _state.searchQuery,
      );
      _emit(
        _state.copyWith(
          isLoading: false,
          ordenes: ordenes,
          rolNombre: rolNombre,
          userId: userId,
        ),
      );
    } catch (e) {
      if (_disposed) return;
      _emit(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void setFiltroEstado(String? estado) {
    _emit(
      _state.copyWith(
        filtroEstado: estado,
        clearFiltroEstado: estado == null,
        visibleCount: kOrdenesPageSize,
      ),
    );
    notifyListeners();
  }

  /// Actualiza el texto de búsqueda y reinicia la paginación.
  /// ProduccionState.ordenesFiltradas ya filtra por este campo
  /// (número, cliente, producto, color, sede, tercero, estado, tipo).
  void setSearch(String query) {
    _emit(
      _state.copyWith(searchQuery: query, visibleCount: kOrdenesPageSize),
    );
  }

  void changeTab(ProduccionTab tab) {
    _emit(_state.copyWith(
      activeTab: tab,
      expandedIds: {},
      visibleCount: kOrdenesPageSize,
    ));
    notifyListeners();
  }

  void toggleExpanded(String id) {
    final isOpen = _state.expandedIds.contains(id);
    final newSet = isOpen ? <String>{} : <String>{id};
    _emit(_state.copyWith(expandedIds: newSet));
  }

  void showMore() {
    if (!_state.hasMore) return;
    _emit(_state.copyWith(
      visibleCount: _state.visibleCount + kOrdenesPageSize,
    ));
  }

  List<String> get estadosDisponibles {
    final all = _state.ordenes.map((o) => o.estado).toSet().toList();
    all.sort();
    return all;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}