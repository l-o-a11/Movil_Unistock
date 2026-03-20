import '../entities/orden_entity.dart';

abstract class OrdenRepository {
  Future<List<OrdenEntity>> getOrdenes({
    OrdenEstado? estado,
    OrdenTipo? tipo,
    String? query,
  });

  Future<OrdenEntity?> getOrdenById(String id);
}
