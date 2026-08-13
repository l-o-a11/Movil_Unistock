// lib/domain/usuarios/domain/usuario_model.dart
//
// Reemplaza el UsuarioEntity anterior (sin id, campos sueltos en texto).
// Este modelo matchea EXACTAMENTE lo que devuelve GET /api/usuarios:
// { id, tipoDocumento, numeroDocumento, nombreCompleto, correo,
//   rolId, rolNombre, sedeId, estado }
//
// Nota: la API solo da sedeId (ObjectId), no el nombre legible de la sede.
// Si más adelante quieres mostrar el nombre, hay que agregar un populate
// en el backend (UserRepository.findAll) o un segundo fetch a /api/sedes.

class UsuarioModel {
  final String id;
  final String tipoDocumento;
  final String numeroDocumento;
  final String nombreCompleto;
  final String correo;
  final String rolId;
  final String? rolNombre;
  final String sedeId;
  final bool estado;

  const UsuarioModel({
    required this.id,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.nombreCompleto,
    required this.correo,
    required this.rolId,
    this.rolNombre,
    required this.sedeId,
    required this.estado,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
    // MongoDB siempre da IDs como String — nunca como int
    id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
    tipoDocumento: json['tipoDocumento']?.toString() ?? '',
    numeroDocumento: json['numeroDocumento']?.toString() ?? '',
    nombreCompleto: json['nombreCompleto']?.toString() ?? '',
    correo: json['correo']?.toString() ?? '',
    rolId: json['rolId']?.toString() ?? '',
    rolNombre: json['rolNombre']?.toString(),
    sedeId: json['sedeId']?.toString() ?? '',
    estado: json['estado'] as bool? ?? true,
  );

  // ── Helpers de presentación ────────────────────────────────────────────
  String get estadoLabel => estado ? 'ACTIVO' : 'INACTIVO';

  // Empleados = SOLO usuarios cuyo rol es exactamente "Empleado" (igual
  // que el backend, ver GetEmployeeWorkload.js: normalizar(rolNombre) ===
  // "empleado"). Antes esto era "cualquier rol que no sea administrativo",
  // lo cual incluía roles como Gerente si no estaban en la lista de
  // administrativos — ahora es un match exacto.
  bool get esEmpleado => rolNombre?.trim().toLowerCase() == 'empleado';

  UsuarioModel copyWith({bool? estado}) => UsuarioModel(
    id: id,
    tipoDocumento: tipoDocumento,
    numeroDocumento: numeroDocumento,
    nombreCompleto: nombreCompleto,
    correo: correo,
    rolId: rolId,
    rolNombre: rolNombre,
    sedeId: sedeId,
    estado: estado ?? this.estado,
  );
}
