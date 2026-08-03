// lib/domain/auth/domain/auth_user.dart
//
// Representa al usuario autenticado en la sesión actual.
// Tiene el mismo shape que devuelve User.toPublic() en el backend
// (y por tanto que POST /auth/login → data.user y PUT /auth/profile → data):
// { id, tipoDocumento, numeroDocumento, nombreCompleto, correo,
//   rolId, rolNombre, sedeId, estado }
//
// Se guarda en almacenamiento seguro junto al token (ver ApiClient.saveUser)
// para no tener que pedir un GET extra solo para precargar "Editar perfil".

class AuthUser {
  final String id;
  final String tipoDocumento;
  final String numeroDocumento;
  final String nombreCompleto;
  final String correo;
  final String rolId;
  final String? rolNombre;
  final String sedeId;
  final bool estado;

  const AuthUser({
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

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'tipoDocumento': tipoDocumento,
    'numeroDocumento': numeroDocumento,
    'nombreCompleto': nombreCompleto,
    'correo': correo,
    'rolId': rolId,
    'rolNombre': rolNombre,
    'sedeId': sedeId,
    'estado': estado,
  };

  String get iniciales {
    final partes = nombreCompleto.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  AuthUser copyWith({String? nombreCompleto, String? correo}) => AuthUser(
    id: id,
    tipoDocumento: tipoDocumento,
    numeroDocumento: numeroDocumento,
    nombreCompleto: nombreCompleto ?? this.nombreCompleto,
    correo: correo ?? this.correo,
    rolId: rolId,
    rolNombre: rolNombre,
    sedeId: sedeId,
    estado: estado,
  );
}
