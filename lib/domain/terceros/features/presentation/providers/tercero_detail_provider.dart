import 'package:flutter/material.dart';

import '../../domain/usecases/get_tercero_detail_usecase.dart';
import '../state/tercero_detail_state.dart';
import '../../data/services/terceros_api_service.dart';

class TerceroDetailProvider extends ChangeNotifier {
  final GetTerceroDetailUseCase getTerceroDetailUseCase;
  final TercerosApiService _apiService;

  TerceroDetailState _state = const TerceroDetailState();
  TerceroDetailState get state => _state;

  TerceroDetailProvider({
    required this.getTerceroDetailUseCase,
    TercerosApiService? apiService,
  }) : _apiService = apiService ?? TercerosApiService();

  Future<void> loadDetail(String id) async {
    _state = _state.copyWith(status: TerceroDetailStatus.loading);
    notifyListeners();
    try {
      final detail = await _apiService.getTerceroDetail(id);
      _state = detail == null
          ? _state.copyWith(status: TerceroDetailStatus.error, error: 'Tercero no encontrado')
          : _state.copyWith(status: TerceroDetailStatus.loaded, detail: detail);
    } catch (e) {
      _state = _state.copyWith(status: TerceroDetailStatus.error, error: 'Error: $e');
    }
    notifyListeners();
  }
}
