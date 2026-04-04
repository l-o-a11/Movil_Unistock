import '../../domain/entities/orden_detail_entity.dart';

/// Estado del detalle de una orden.
///
/// Propiedades:
/// - [isLoading]: indica carga en progreso
/// - [error]: mensaje de error (null si no hay error)
/// - [detail]: detalle completo de la orden (null si no cargado)
class OrdenDetailState {
  final bool isLoading;
  final String? error;
  final OrdenDetailEntity? detail;

  const OrdenDetailState({this.isLoading = false, this.error, this.detail});

  bool get hasError => error != null;
  bool get isLoaded => !isLoading && error == null && detail != null;

  OrdenDetailState copyWith({
    bool? isLoading,
    String? error,
    OrdenDetailEntity? detail,
  }) {
    return OrdenDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      detail: detail ?? this.detail,
    );
  }
}
