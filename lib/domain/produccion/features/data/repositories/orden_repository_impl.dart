import '../../domain/entities/orden_entity.dart';
import '../../domain/entities/orden_detail_entity.dart';
import '../../domain/repositories/orden_repository.dart';
import '../datasources/orden_local_datasource.dart';

/// Implementación de [OrdenRepository].
///
/// Delega todas las operaciones al datasource local [OrdenLocalDataSource].
/// En producción se puede extender para consumir API remota.
class OrdenRepositoryImpl implements OrdenRepository {
  /// Construye el repositorio con un datasource local.
  final OrdenLocalDataSource localDataSource;

  const OrdenRepositoryImpl({required this.localDataSource});

  @override
  Future<List<OrdenEntity>> getOrdenes({
    String? estado,
    String? tipo,
    String? query,
  }) async {
    return localDataSource.getOrdenes(estado: estado, tipo: tipo, query: query);
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
