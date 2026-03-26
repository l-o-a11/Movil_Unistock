import '../../domain/entities/tercero_detail_entity.dart';

enum TerceroDetailStatus { initial, loading, loaded, error }

class TerceroDetailState {
  final TerceroDetailStatus status;
  final TerceroDetailEntity? detail;
  final String? error;

  const TerceroDetailState({
    this.status = TerceroDetailStatus.initial,
    this.detail,
    this.error,
  });

  bool get isLoading => status == TerceroDetailStatus.loading;
  bool get hasError   => status == TerceroDetailStatus.error;
  bool get isLoaded   => status == TerceroDetailStatus.loaded;

  TerceroDetailState copyWith({
    TerceroDetailStatus? status,
    TerceroDetailEntity? detail,
    String? error,
  }) {
    return TerceroDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      error: error,
    );
  }
}
