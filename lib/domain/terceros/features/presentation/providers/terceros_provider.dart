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

  TercerosState _state = const TercerosState();
  TercerosState get state => _state;

  TercerosProvider({
    required this.getTercerosUseCase,
    TercerosApiService? apiService,
  }) : _apiService = apiService ?? TercerosApiService() {
    loadTerceros();
  }

  /// Carga la lista de terceros desde el servicio API.
  /// 
  /// Si hay una búsqueda activa, filtra los terceros automáticamente.
  Future<void> loadTerceros() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    try {
      final terceros = await _apiService.getTerceros(
        query: _state.searchQuery.isNotEmpty ? _state.searchQuery : null,
      );
      _state = _state.copyWith(terceros: terceros, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: 'Error al cargar terceros: $e');
    }
    notifyListeners();
  }

  /// Actualiza la consulta de búsqueda y recarga los terceros.
  /// 
  /// Parámetro:
  /// - [query]: Término de búsqueda (actualiza estado y recarga)
  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
    loadTerceros();
  }
}
