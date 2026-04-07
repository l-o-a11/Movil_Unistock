/// Estado de un proveedor en el sistema.
enum ProveedorEstado { activo, inactivo }

/// Entidad de proveedor de materiales/servicios.
/// 
/// Contiene datos de identificación, contacto e información web.
/// Utilizada por el módulo Proveedores para mostrar lista de proveedores.
class ProveedorEntity {
  final String id, nit, nombre, contacto, direccion, telefono, correo, sitioWeb;
  final ProveedorEstado estado;
  const ProveedorEntity({required this.id, required this.nit, required this.nombre,
    required this.contacto, required this.direccion, required this.telefono,
    required this.correo, required this.sitioWeb, required this.estado});
  bool get isActivo => estado == ProveedorEstado.activo;
  String get estadoLabel => isActivo ? 'ACTIVO' : 'INACTIVO';
}
