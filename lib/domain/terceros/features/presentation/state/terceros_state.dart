import '../../domain/entities/tercero_entity.dart';

/// Estado de la lista de terceros.
///
/// Propiedades:
/// - [terceros]: lista completa de terceros (sin filtrar)
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

  bool get searchActive => searchQuery.trim().isNotEmpty;

  bool get hasResults => tercerosFiltrados.isNotEmpty;

  /// Terceros filtrados localmente por el término de búsqueda.
  ///
  /// Busca sin distinguir mayúsculas/minúsculas en: nombre, código, NIT,
  /// contacto, teléfono y dirección. Si no hay búsqueda activa, retorna la
  /// lista completa.
  List<TerceroEntity> get tercerosFiltrados {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return terceros;
    return terceros.where((t) {
      return t.nombre.toLowerCase().contains(q) ||
          t.codigo.toLowerCase().contains(q) ||
          t.nit.toLowerCase().contains(q) ||
          t.contacto.toLowerCase().contains(q) ||
          t.telefono.toLowerCase().contains(q) ||
          t.direccion.toLowerCase().contains(q);
    }).toList();
  }

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
