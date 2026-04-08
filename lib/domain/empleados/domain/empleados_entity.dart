/// Entidad de dominio para empleados.
class EmpleadoEntity {
  final String doc;
  final String nombre;
  final String email;
  final String estado;
  final String cargo;
  final String sede;

  const EmpleadoEntity({
    required this.doc,
    required this.nombre,
    required this.email,
    required this.estado,
    required this.cargo,
    required this.sede,
  });
}
