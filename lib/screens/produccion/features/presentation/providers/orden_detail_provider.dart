import 'package:flutter/material.dart';

import '../../domain/usecases/get_orden_detail_usecase.dart';
import '../state/orden_detail_state.dart';

class OrdenDetailProvider extends ChangeNotifier {
  final GetOrdenDetailUseCase getOrdenDetailUseCase;

  OrdenDetailState _state = const OrdenDetailState();
  OrdenDetailState get state => _state;

  OrdenDetailProvider({required this.getOrdenDetailUseCase});

  Future<void> loadDetail(String id) async {
    _state = _state.copyWith(status: OrdenDetailStatus.loading);
    notifyListeners();

    try {
      final detail = await getOrdenDetailUseCase(id);
      if (detail == null) {
        _state = _state.copyWith(
          status: OrdenDetailStatus.error,
          error: 'Orden no encontrada',
        );
      } else {
        _state = _state.copyWith(
          status: OrdenDetailStatus.loaded,
          detail: detail,
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        status: OrdenDetailStatus.error,
        error: 'Error al cargar el detalle: $e',
      );
    }

    notifyListeners();
  }
}
