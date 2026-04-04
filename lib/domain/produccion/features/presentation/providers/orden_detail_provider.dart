import 'package:flutter/material.dart';
import '../../domain/usecases/get_orden_detail_usecase.dart';
import '../state/orden_detail_state.dart';

/// Proveedor de estado para el detalle de una orden individual.
///
/// Gestiona:
/// - Carga del detalle completo desde [GetOrdenDetailUseCase]
/// - Manejo de errores (orden no encontrada, etc.)
/// - Emisión de estado a través de [OrdenDetailState]
class OrdenDetailProvider extends ChangeNotifier {
  final GetOrdenDetailUseCase getOrdenDetailUseCase;

  OrdenDetailProvider({required this.getOrdenDetailUseCase});

  OrdenDetailState _state = const OrdenDetailState();
  OrdenDetailState get state => _state;

  void _emit(OrdenDetailState s) {
    _state = s;
    notifyListeners();
  }

  /// Carga el detalle completo de una orden por su [id].
  /// Emite estado de carga, error o detalle cargado.
  Future<void> loadDetail(String id) async {
    _emit(const OrdenDetailState(isLoading: true));
    try {
      final detail = await getOrdenDetailUseCase(id);
      if (detail == null) {
        _emit(const OrdenDetailState(error: 'Orden no encontrada'));
      } else {
        _emit(OrdenDetailState(detail: detail));
      }
    } catch (e) {
      _emit(OrdenDetailState(error: e.toString()));
    }
  }
}
