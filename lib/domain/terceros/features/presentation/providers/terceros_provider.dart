import 'package:flutter/material.dart';

import '../../domain/usecases/get_terceros_usecase.dart';
import '../state/terceros_state.dart';
import '../../data/services/terceros_api_service.dart';

/// Proveedor de estado para la lista de terceros.
///
/// Gestiona:
/// - Carga de terceros desde [GetTercerosUseCase]
/// - Búsqueda de texto
/// - Consumo de [TercerosApiService]
///
/// Emite estado a través de [TercerosState].
class TercerosProvider extends ChangeNotifier {
  final GetTercerosUseCase getTercerosUseCase;
  final TercerosApiService _apiService;
  bool _disposed = false;

  TercerosState _state = const TercerosState();
  TercerosState get state => _state;

  TercerosProvider({
    required this.getTercerosUseCase,
    TercerosApiService? apiService,
  }) : _apiService = apiService ?? TercerosApiService() {
    loadTerceros();
  }

  /// Carga la lista completa de terceros desde el servicio API.
  ///
  /// El filtrado por búsqueda se hace localmente en
  /// [TercerosState.tercerosFiltrados], evitando una llamada HTTP por tecla.
  Future<void> loadTerceros() async {
    if (_disposed) return;
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final terceros = await _apiService.getTerceros();
      if (_disposed) return;
      _state = _state.copyWith(terceros: terceros, isLoading: false);
    } catch (e) {
      if (_disposed) return;
      _state = _state.copyWith(
        isLoading: false,
        error: 'Error al cargar terceros: $e',
      );
    }
    if (!_disposed) notifyListeners();
  }

  /// Actualiza la consulta de búsqueda.
  ///
  /// Solo actualiza el estado y notifica — el filtrado se aplica localmente
  /// y de forma instantánea en la UI. Reinicia la paginación a
  /// [kTercerosPageSize] para que la nueva búsqueda siempre empiece
  /// mostrando el primer bloque de resultados.
  ///
  /// Parámetro:
  /// - [query]: Término de búsqueda
  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}