import '../../domain/entities/tercero_entity.dart';

class TercerosState {
  final List<TerceroEntity> terceros;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const TercerosState({
    this.terceros = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  TercerosState copyWith({
    List<TerceroEntity>? terceros,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return TercerosState(
      terceros: terceros ?? this.terceros,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
