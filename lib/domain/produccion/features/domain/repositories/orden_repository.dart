import '../entities/orden_entity.dart';
import '../entities/orden_detail_entity.dart';

/// Contrato de repositorio para acceso a datos de órdenes de producción.
/// Define la interfaz que implementa [OrdenRepositoryImpl].
abstract class OrdenRepository {
  /// Obtiene lista filtrada de órdenes.
  ///
  /// Parámetros:
  /// - [estado]: Filtra por [OrdenEstado] (opcional)
  /// - [tipo]: Filtra por [OrdenTipo] producción o terceros (opcional)
  /// - [query]: Búsqueda por número, cliente o referencia (opcional)
  ///
  /// Retorna lista de [OrdenEntity] que coinciden con los filtros.
  Future<List<OrdenEntity>> getOrdenes({
    OrdenEstado? estado,
    OrdenTipo? tipo,
    String? query,
  });

  /// Obtiene una orden por su ID.
  /// Retorna null si la orden no existe.
  Future<OrdenEntity?> getOrdenById(String id);

  /// Obtiene el detalle completo de una orden (progreso, referencias, historial, ficha).
  /// Incluye información extendida no presente en [OrdenEntity].
  /// Retorna null si la orden no existe.
  Future<OrdenDetailEntity?> getOrdenDetail(String id);
}
