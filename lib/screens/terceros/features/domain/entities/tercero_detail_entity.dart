import 'tercero_entity.dart';
import 'tercero_produccion_entity.dart';

/// Detalle completo de un tercero: extiende [TerceroEntity]
/// con la lista de producciones asociadas.
class TerceroDetailEntity extends TerceroEntity {
  final List<TerceroProduccionEntity> producciones;

  const TerceroDetailEntity({
    required super.id,
    required super.codigo,
    required super.nombre,
    required super.contacto,
    required super.nit,
    required super.direccion,
    required super.telefono,
    required super.estado,
    required this.producciones,
  });
}
