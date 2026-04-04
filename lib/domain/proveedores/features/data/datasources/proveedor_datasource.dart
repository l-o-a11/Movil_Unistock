import '../../domain/entities/proveedor_entity.dart';

/// DataSource local (mock) con datos de 4 proveedores.
/// 
/// Proporciona operaciones de lectura para la lista de proveedores.
/// Soporta filtrado por nombre, NIT y contacto.
class ProveedorDataSource {
  static final List<ProveedorEntity> _data = [
    const ProveedorEntity(id:'1', nit:'1235', nombre:'Antonia Design',
      contacto:'Antonia Ramirez', direccion:'Cll 50 #90-5, Medellín',
      telefono:'32541658424', correo:'antonia@design.co', sitioWeb:'antoniadesign.co',
      estado:ProveedorEstado.activo),
    const ProveedorEntity(id:'2', nit:'1045', nombre:'Susana Textil',
      contacto:'Antonia María', direccion:'Carrera 70 #45-12, Medellín',
      telefono:'31452367890', correo:'susana@textil.com', sitioWeb:'susanatextil.com',
      estado:ProveedorEstado.activo),
    const ProveedorEntity(id:'3', nit:'1045', nombre:'Susana Textil',
      contacto:'Antonia María', direccion:'Carrera 70 #45-12, Medellín',
      telefono:'31452367890', correo:'susana@textil.com', sitioWeb:'susanatextil.com',
      estado:ProveedorEstado.activo),
    const ProveedorEntity(id:'4', nit:'2001', nombre:'Modas Elena',
      contacto:'Elena Gómez', direccion:'Av. El Poblado #15-30, Medellín',
      telefono:'30098765432', correo:'elena@modas.co', sitioWeb:'modaselena.co',
      estado:ProveedorEstado.inactivo),
  ];

  /// Obtiene lista de proveedores con búsqueda opcional.
  /// 
  /// Parámetro:
  /// - [query]: Filtra por nombre, NIT o contacto (opcional)
  /// 
  /// Retorna lista de [ProveedorEntity] que coinciden.
  Future<List<ProveedorEntity>> getAll({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 260));
    if (query == null || query.isEmpty) return _data;
    final q = query.toLowerCase();
    return _data.where((p) => p.nombre.toLowerCase().contains(q) ||
        p.nit.contains(q) || p.contacto.toLowerCase().contains(q)).toList();
  }
}
