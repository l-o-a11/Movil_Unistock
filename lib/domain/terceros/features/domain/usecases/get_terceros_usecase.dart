import '../entities/tercero_entity.dart';
import '../repositories/tercero_repository.dart';

/// Caso de uso: obtiene lista de terceros con búsqueda opcional.
///
/// Encapsula la lógica de negocio para recuperar terceros del repositorio.
/// Utilizado por [TercerosProvider].
class GetTercerosUseCase {
  final TerceroRepository repository;
  const GetTercerosUseCase(this.repository);

  /// Obtiene terceros filtrados por búsqueda de texto.
  ///
  /// Parámetro:
  /// - [query]: Término de búsqueda (opcional, filtra por nombre/código)
  ///
  /// Retorna lista de [TerceroEntity] que coinciden con la búsqueda.
  Future<List<TerceroEntity>> call({String? query}) =>
      repository.getTerceros(query: query);
}
