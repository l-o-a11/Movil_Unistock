import 'package:flutter/material.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';
import '../../domain/usecases/get_orden_detail_usecase.dart';
import '../../domain/usecases/avanzar_estado_usecase.dart';
import '../../domain/usecases/confirmar_etapa_usecase.dart';
import '../state/orden_detail_state.dart';

/// Proveedor de estado para el detalle de una orden individual.
///
/// Gestiona:
/// - Carga del detalle completo desde [GetOrdenDetailUseCase]
/// - Rol del usuario logueado (Gerente / Administrador / Empleado), para
///   decidir qué vista y qué botón de avance mostrar — espejo de
///   `useSedeScope()` en ProductionDetailsPage.jsx
/// - Acciones de avance: `avanzarEstado` (Gerente) y `confirmarEtapa`
///   (Empleado), espejo de `ProductionAPIClient.changeOrderStatus` /
///   `confirmarEtapa` en el frontend web
/// - Manejo de errores (orden no encontrada, etc.)
/// - Emisión de estado a través de [OrdenDetailState]
class OrdenDetailProvider extends ChangeNotifier {
  final GetOrdenDetailUseCase getOrdenDetailUseCase;
  final AvanzarEstadoUseCase? avanzarEstadoUseCase;
  final ConfirmarEtapaUseCase? confirmarEtapaUseCase;
  final AuthService _auth;

  OrdenDetailProvider({
    required this.getOrdenDetailUseCase,
    this.avanzarEstadoUseCase,
    this.confirmarEtapaUseCase,
    AuthService? auth,
  }) : _auth = auth ?? AuthService();

  OrdenDetailState _state = const OrdenDetailState();
  OrdenDetailState get state => _state;

  void _emit(OrdenDetailState s) {
    _state = s;
    notifyListeners();
  }

  /// Carga el detalle completo de una orden por su [id] junto con el rol
  /// del usuario logueado. Emite estado de carga, error o detalle cargado.
  Future<void> loadDetail(String id) async {
    _emit(const OrdenDetailState(isLoading: true));
    try {
      final rolNombre = await _auth.getRolNombre();
      final detail = await getOrdenDetailUseCase(id);
      if (detail == null) {
        _emit(OrdenDetailState(error: 'Orden no encontrada', rolNombre: rolNombre));
      } else {
        _emit(OrdenDetailState(detail: detail, rolNombre: rolNombre));
      }
    } catch (e) {
      _emit(OrdenDetailState(error: e.toString()));
    }
  }

  /// Avanza la orden al [nuevoEstado] — solo debe llamarse cuando
  /// `state.isGerente` es true. Refresca el detalle en caso de éxito.
  Future<bool> avanzarEstado(String id, String nuevoEstado) async {
    if (avanzarEstadoUseCase == null) return false;
    _emit(_state.copyWith(isActionLoading: true, clearActionError: true));
    try {
      final updated = await avanzarEstadoUseCase!(id, nuevoEstado);
      if (updated != null) {
        _emit(_state.copyWith(detail: updated, isActionLoading: false));
        return true;
      }
      _emit(_state.copyWith(isActionLoading: false, actionError: 'No se pudo avanzar la orden.'));
      return false;
    } catch (e) {
      _emit(_state.copyWith(isActionLoading: false, actionError: e.toString()));
      return false;
    }
  }

  /// El empleado asignado confirma que terminó la etapa actual — solo
  /// debe llamarse cuando `state.isEmpleado` es true.
  Future<bool> confirmarEtapa(String id) async {
    if (confirmarEtapaUseCase == null) return false;
    _emit(_state.copyWith(isActionLoading: true, clearActionError: true));
    try {
      final updated = await confirmarEtapaUseCase!(id);
      if (updated != null) {
        _emit(_state.copyWith(detail: updated, isActionLoading: false));
        return true;
      }
      _emit(_state.copyWith(isActionLoading: false, actionError: 'No se pudo confirmar la etapa.'));
      return false;
    } catch (e) {
      _emit(_state.copyWith(isActionLoading: false, actionError: e.toString()));
      return false;
    }
  }
}
