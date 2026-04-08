import '../domain/usuarios_entity.dart';

/// DataSource local (mock) para usuarios.
class UsuariosDataSource {
  final List<UsuarioEntity> _usuarios = [
    UsuarioEntity(
      doc: 'DOC: 1883127436',
      nombre: 'Sofia Osorio',
      email: 'sofiaosorio@gmail.com',
      estado: 'ACTIVO',
      rol: 'Empleado',
      sede: 'Parque la 93',
    ),
    UsuarioEntity(
      doc: 'DOC: 1123783628',
      nombre: 'Mia Flores Martinez',
      email: 'miaflorez@gmail.com',
      estado: 'ACTIVO',
      rol: 'Gerente',
      sede: 'Centro',
    ),
    UsuarioEntity(
      doc: 'DOC: 1566432376',
      nombre: 'Antonio Sanchez',
      email: 'asanchez@gmail.com',
      estado: 'ACTIVO',
      rol: 'Administrador',
      sede: 'Parque la 93',
    ),
    UsuarioEntity(
      doc: 'DOC: 2234567890',
      nombre: 'Daniela Rivas',
      email: 'daniela.rivas@company.com',
      estado: 'INACTIVO',
      rol: 'Empleado',
      sede: 'Laureles',
    ),
    UsuarioEntity(
      doc: 'DOC: 3344556677',
      nombre: 'Javier Torres',
      email: 'javier.torres@company.com',
      estado: 'ACTIVO',
      rol: 'Gerente',
      sede: 'El Poblado',
    ),
  ];

  Future<List<UsuarioEntity>> getUsuarios({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final value = query?.trim().toLowerCase();
    if (value == null || value.isEmpty) {
      return _usuarios;
    }

    return _usuarios.where((usuario) {
      return usuario.nombre.toLowerCase().contains(value) ||
          usuario.doc.toLowerCase().contains(value) ||
          usuario.rol.toLowerCase().contains(value) ||
          usuario.sede.toLowerCase().contains(value);
    }).toList();
  }
}
