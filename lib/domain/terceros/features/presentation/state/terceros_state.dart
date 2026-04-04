import '../../domain/entities/tercero_entity.dart';

/// Estado de la lista de terceros.
/// 
/// Propiedades:
/// - [terceros]: lista filtrada de terceros
/// - [isLoading]: indica carga en progreso
/// - [error]: mensaje de error (null si no hay error)
/// - [searchQuery]: término de búsqueda actual
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
