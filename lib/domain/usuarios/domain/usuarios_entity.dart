/// Entidad de dominio para usuarios.
// Test comment
class UsuarioEntity {
  final String doc;
  final String nombre;
  final String email;
  final String estado;
  final String rol;
  final String sede;

  const UsuarioEntity({
    required this.doc,
    required this.nombre,
    required this.email,
    required this.estado,
    required this.rol,
    required this.sede,
  });
}
