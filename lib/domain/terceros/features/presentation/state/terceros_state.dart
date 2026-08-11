import '../../domain/entities/tercero_entity.dart';

/// Cantidad de registros que se muestran por "página" al listar terceros.
const int kTercerosPageSize = 5;

/// Estado de la lista de terceros.
///
/// Propiedades:
/// - [terceros]: lista completa de terceros (sin filtrar)
/// - [isLoading]: indica carga en progreso
/// - [error]: mensaje de error (null si no hay error)
/// - [searchQuery]: término de búsqueda actual
/// - [visibleCount]: cantidad de registros visibles actualmente (paginación
///   local con botón "Ver más")
class TercerosState {
  final List<TerceroEntity> terceros;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int visibleCount;

  const TercerosState({
    this.terceros = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.visibleCount = kTercerosPageSize,
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

  /// Subconjunto de [tercerosFiltrados] que debe mostrarse en pantalla,
  /// según la paginación actual ([visibleCount]).
  List<TerceroEntity> get tercerosVisibles {
    final filtrados = tercerosFiltrados;
    if (visibleCount >= filtrados.length) return filtrados;
    return filtrados.take(visibleCount).toList();
  }

  /// Indica si hay más registros filtrados de los que se están mostrando,
  /// es decir, si debe mostrarse el botón "Ver más".
  bool get hasMore => visibleCount < tercerosFiltrados.length;

  TercerosState copyWith({
    List<TerceroEntity>? terceros,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? visibleCount,
  }) {
    return TercerosState(
      terceros: terceros ?? this.terceros,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      visibleCount: visibleCount ?? this.visibleCount,
    );
  }
}