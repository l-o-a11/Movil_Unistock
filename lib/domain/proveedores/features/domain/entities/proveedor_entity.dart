enum ProveedorEstado { activo, inactivo }

class ProveedorEntity {
  final String id, nit, nombre, contacto, direccion, telefono, correo, sitioWeb;
  final ProveedorEstado estado;
  const ProveedorEntity({required this.id, required this.nit, required this.nombre,
    required this.contacto, required this.direccion, required this.telefono,
    required this.correo, required this.sitioWeb, required this.estado});
  bool get isActivo => estado == ProveedorEstado.activo;
  String get estadoLabel => isActivo ? 'ACTIVO' : 'INACTIVO';
}
