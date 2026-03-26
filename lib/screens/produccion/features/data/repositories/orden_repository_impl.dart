import '../../domain/entities/orden_entity.dart';
import '../../domain/entities/orden_detail_entity.dart';
import '../../domain/repositories/orden_repository.dart';
import '../datasources/orden_local_datasource.dart';

class OrdenRepositoryImpl implements OrdenRepository {
  final OrdenLocalDataSource localDataSource;

  const OrdenRepositoryImpl({required this.localDataSource});

  @override
  Future<List<OrdenEntity>> getOrdenes({
    OrdenEstado? estado,
    OrdenTipo? tipo,
    String? query,
  }) async {
    return localDataSource.getOrdenes(
      estado: estado,
      tipo: tipo,
      query: query,
    );
  }

  @override
  Future<OrdenEntity?> getOrdenById(String id) async {
    final ordenes = await localDataSource.getOrdenes();
    try {
      return ordenes.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<OrdenDetailEntity?> getOrdenDetail(String id) {
    return localDataSource.getOrdenDetail(id);
  }
}
