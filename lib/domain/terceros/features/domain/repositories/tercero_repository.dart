import '../entities/tercero_entity.dart';
import '../entities/tercero_detail_entity.dart';

/// Contrato de repositorio para acceso a datos de terceros.
/// Define la interfaz que implementa [TerceroRepositoryImpl].
abstract class TerceroRepository {
  /// Obtiene lista de terceros filtrada por búsqueda de texto.
  /// Filtra por nombre, código y contacto.
  Future<List<TerceroEntity>> getTerceros({String? query});

  /// Obtiene el detalle completo de un tercero por ID.
  /// Incluye lista de órdenes de producción asociadas.
  Future<TerceroDetailEntity?> getTerceroDetail(String id);
}
