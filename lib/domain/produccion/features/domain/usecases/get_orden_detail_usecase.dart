import '../entities/orden_detail_entity.dart';
import '../repositories/orden_repository.dart';

/// Caso de uso: obtiene el detalle completo de una orden por su [id].
class GetOrdenDetailUseCase {
  final OrdenRepository repository;

  const GetOrdenDetailUseCase(this.repository);

  Future<OrdenDetailEntity?> call(String id) {
    return repository.getOrdenDetail(id);
  }
}
