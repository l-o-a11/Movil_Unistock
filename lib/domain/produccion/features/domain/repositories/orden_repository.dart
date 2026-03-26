import '../entities/orden_entity.dart';
import '../entities/orden_detail_entity.dart';

abstract class OrdenRepository {
  Future<List<OrdenEntity>> getOrdenes({
    OrdenEstado? estado,
    OrdenTipo? tipo,
    String? query,
  });

  Future<OrdenEntity?> getOrdenById(String id);

  /// Retorna el detalle completo de una orden (progreso, referencias, historial, ficha).
  Future<OrdenDetailEntity?> getOrdenDetail(String id);
}
