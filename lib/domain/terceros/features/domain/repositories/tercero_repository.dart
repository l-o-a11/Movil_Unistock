import '../entities/tercero_entity.dart';
import '../entities/tercero_detail_entity.dart';

abstract class TerceroRepository {
  Future<List<TerceroEntity>> getTerceros({String? query});
  Future<TerceroDetailEntity?> getTerceroDetail(String id);
}
