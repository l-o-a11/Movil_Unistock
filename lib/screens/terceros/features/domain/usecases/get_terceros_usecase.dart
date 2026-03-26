import '../entities/tercero_entity.dart';
import '../repositories/tercero_repository.dart';

class GetTercerosUseCase {
  final TerceroRepository repository;
  const GetTercerosUseCase(this.repository);

  Future<List<TerceroEntity>> call({String? query}) =>
      repository.getTerceros(query: query);
}
