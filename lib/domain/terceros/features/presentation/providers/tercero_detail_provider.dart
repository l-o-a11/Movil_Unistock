import 'package:flutter/material.dart';

import '../../domain/usecases/get_tercero_detail_usecase.dart';
import '../state/tercero_detail_state.dart';

/// Proveedor de estado para el detalle de un tercero individual.
///
/// Gestiona:
/// - Carga del detalle completo desde [GetTerceroDetailUseCase]
/// - Manejo de errores (tercero no encontrado, etc)
/// - Emisión de estado a través de [TerceroDetailState]
class TerceroDetailProvider extends ChangeNotifier {
  final GetTerceroDetailUseCase getTerceroDetailUseCase;

  TerceroDetailState _state = const TerceroDetailState();
  TerceroDetailState get state => _state;

  TerceroDetailProvider({required this.getTerceroDetailUseCase});

  /// Carga el detalle completo de un tercero por su [id].
  ///
  /// Emite estado de carga → cargado o error.
  Future<void> loadDetail(String id) async {
    _state = _state.copyWith(status: TerceroDetailStatus.loading);
    notifyListeners();
    try {
      final detail = await getTerceroDetailUseCase(id);
      _state = detail == null
          ? _state.copyWith(status: TerceroDetailStatus.error, error: 'Tercero no encontrado')
          : _state.copyWith(status: TerceroDetailStatus.loaded, detail: detail);
    } catch (e) {
      _state = _state.copyWith(status: TerceroDetailStatus.error, error: 'Error: $e');
    }
    notifyListeners();
  }
}