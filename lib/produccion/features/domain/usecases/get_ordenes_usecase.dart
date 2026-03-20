import '../entities/orden_entity.dart';
import '../repositories/orden_repository.dart';

class GetOrdenesUseCase {
  final OrdenRepository repository;

  const GetOrdenesUseCase(this.repository);

  Future<List<OrdenEntity>> call({
    OrdenEstado? estado,
    OrdenTipo? tipo,
    String? query,
  }) {
    return repository.getOrdenes(
      estado: estado,
      tipo: tipo,
      query: query,
    );
  }
}
