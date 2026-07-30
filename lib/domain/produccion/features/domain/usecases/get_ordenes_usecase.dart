import '../entities/orden_entity.dart';
import '../repositories/orden_repository.dart';

/// Caso de uso: obtiene lista de órdenes con filtros opcionales.
///
/// Encapsula la lógica de negocio para recuperar órdenes del repositorio.
/// Utilizado por [ProduccionProvider].
class GetOrdenesUseCase {
  final OrdenRepository repository;

  const GetOrdenesUseCase(this.repository);

  /// Obtiene órdenes filtradas por estado, tipo y/o búsqueda.
  ///
  /// Parámetros:
  /// - [estado]: Filtra por [OrdenEstado] (opcional)
  /// - [tipo]: Filtra por [OrdenTipo] (opcional)
  /// - [query]: Búsqueda de texto (opcional)
  ///
  /// Retorna lista de [OrdenEntity] que coinciden con los criterios.
  Future<List<OrdenEntity>> call({
    String? estado,
    String? tipo,
    String? query,
  }) {
    return repository.getOrdenes(estado: estado, tipo: tipo, query: query);
  }
}
