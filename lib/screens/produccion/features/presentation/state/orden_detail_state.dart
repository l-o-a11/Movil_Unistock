import '../../domain/entities/orden_detail_entity.dart';

enum OrdenDetailStatus { initial, loading, loaded, error }

class OrdenDetailState {
  final OrdenDetailStatus status;
  final OrdenDetailEntity? detail;
  final String? error;

  const OrdenDetailState({
    this.status = OrdenDetailStatus.initial,
    this.detail,
    this.error,
  });

  bool get isLoading => status == OrdenDetailStatus.loading;
  bool get hasError => status == OrdenDetailStatus.error;
  bool get isLoaded => status == OrdenDetailStatus.loaded;

  OrdenDetailState copyWith({
    OrdenDetailStatus? status,
    OrdenDetailEntity? detail,
    String? error,
  }) {
    return OrdenDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      error: error,
    );
  }
}
