enum TerceroEstado { activo, inactivo }

/// Entidad base de un tercero (proveedor / subcontratista).
class TerceroEntity {
  final String id;
  final String codigo;
  final String nombre;
  final String contacto;
  final String nit;
  final String direccion;
  final String telefono;
  final TerceroEstado estado;

  const TerceroEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.contacto,
    required this.nit,
    required this.direccion,
    required this.telefono,
    required this.estado,
  });

  String get estadoLabel =>
      estado == TerceroEstado.activo ? 'Activo' : 'Inactivo';

  bool get isActivo => estado == TerceroEstado.activo;
}
