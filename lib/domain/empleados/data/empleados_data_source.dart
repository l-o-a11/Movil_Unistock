import '../domain/empleados_entity.dart';

/// DataSource local (mock) para empleados.
class EmpleadosDataSource {
  final List<EmpleadoEntity> _empleados = const [
    EmpleadoEntity(
      doc: 'DOC: 1883127436',
      nombre: 'Sofia Osorio',
      email: 'sofiaosorio@gmail.com',
      estado: 'ACTIVO',
      cargo: 'Vendedor',
      sede: 'Parque la 93',
    ),
    EmpleadoEntity(
      doc: 'DOC: 1123783628',
      nombre: 'Mia Flores Martinez',
      email: 'miaflorez@gmail.com',
      estado: 'ACTIVO',
      cargo: 'Gerente',
      sede: 'Centro',
    ),
    EmpleadoEntity(
      doc: 'DOC: 1566432376',
      nombre: 'Antonio Sanchez',
      email: 'asanchez@gmail.com',
      estado: 'ACTIVO',
      cargo: 'Asistente',
      sede: 'Parque la 93',
    ),
  ];

  Future<List<EmpleadoEntity>> getEmpleados({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final value = query?.trim().toLowerCase();
    if (value == null || value.isEmpty) {
      return _empleados;
    }

    return _empleados.where((empleado) {
      return empleado.nombre.toLowerCase().contains(value) ||
          empleado.doc.toLowerCase().contains(value) ||
          empleado.cargo.toLowerCase().contains(value) ||
          empleado.sede.toLowerCase().contains(value);
    }).toList();
  }
}
