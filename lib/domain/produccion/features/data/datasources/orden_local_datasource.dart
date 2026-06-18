import '../models/orden_model.dart';
import '../../domain/entities/orden_detail_entity.dart';

/// Contrato para acceso local a datos de órdenes.
abstract class OrdenLocalDataSource {
  Future<List<OrdenModel>> getOrdenes({
    String? estado,
    String? tipo,
    String? query,
  });

  Future<OrdenDetailEntity?> getOrdenDetail(String id);
}

/// Implementación local de [OrdenLocalDataSource].
/// En producción, los datos provienen de la API. Este fallback sirve
/// como mock para desarrollo cuando no hay conexión.
class OrdenLocalDataSourceImpl implements OrdenLocalDataSource {
  @override
  Future<List<OrdenModel>> getOrdenes({
    String? estado,
    String? tipo,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 260));
    // TODO: Implementar conexión a API real
    return [];
  }

  @override
  Future<OrdenDetailEntity?> getOrdenDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 180));
    // TODO: Implementar conexión a API real
    return null;
  }
}
