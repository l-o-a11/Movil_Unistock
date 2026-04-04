import 'package:flutter/material.dart';

import '../../domain/usecases/get_terceros_usecase.dart';
import '../state/terceros_state.dart';
import '../../data/services/terceros_api_service.dart';

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

  void updateSearch(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
    loadTerceros();
  }
}
