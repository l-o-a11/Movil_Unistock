import '../entities/tercero_detail_entity.dart';
import '../repositories/tercero_repository.dart';

/// Caso de uso: obtiene el detalle completo de un tercero por ID.
///
/// Incluye información de órdenes de producción asociadas.
/// Utilizado por [TerceroDetailProvider].
class GetTerceroDetailUseCase {
  final TerceroRepository repository;
  const GetTerceroDetailUseCase(this.repository);

  /// Obtiene el detalle completo de un tercero por su [id].
  Future<TerceroDetailEntity?> call(String id) =>
      repository.getTerceroDetail(id);
}
