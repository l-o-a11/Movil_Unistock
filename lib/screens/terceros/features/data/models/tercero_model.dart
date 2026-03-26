import '../../domain/entities/tercero_entity.dart';

class TerceroModel extends TerceroEntity {
  const TerceroModel({
    required super.id,
    required super.codigo,
    required super.nombre,
    required super.contacto,
    required super.nit,
    required super.direccion,
    required super.telefono,
    required super.estado,
  });
}
