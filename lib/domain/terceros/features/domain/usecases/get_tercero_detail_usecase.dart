import '../entities/tercero_detail_entity.dart';
import '../repositories/tercero_repository.dart';

class GetTerceroDetailUseCase {
  final TerceroRepository repository;
  const GetTerceroDetailUseCase(this.repository);

  Future<TerceroDetailEntity?> call(String id) =>
      repository.getTerceroDetail(id);
}
