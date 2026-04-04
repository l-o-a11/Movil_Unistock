import '../../domain/entities/tercero_entity.dart';
import '../../domain/entities/tercero_detail_entity.dart';
import '../../domain/repositories/tercero_repository.dart';
import '../datasources/tercero_local_datasource.dart';

/// Implementación de [TerceroRepository].
/// 
/// Delega todas las operaciones al datasource local [TerceroLocalDataSource].
/// En producción se puede extender para consumir API remota.
class TerceroRepositoryImpl implements TerceroRepository {
  final TerceroLocalDataSource localDataSource;
  const TerceroRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TerceroEntity>> getTerceros({String? query}) =>
      localDataSource.getTerceros(query: query);

  @override
  Future<TerceroDetailEntity?> getTerceroDetail(String id) =>
      localDataSource.getTerceroDetail(id);
}
