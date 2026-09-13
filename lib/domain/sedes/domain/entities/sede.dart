class Sede {
  final String id;
  final String nombre;
  final String ciudad;
  final String barrio;
  final String direccion;
  final String telefono;
  final bool estado;

  const Sede({
    required this.id,
    required this.nombre,
    required this.ciudad,
    required this.barrio,
    required this.direccion,
    required this.telefono,
    required this.estado,
  });

  String get estadoLabel => estado ? 'Activo' : 'Inactivo';
  bool get isActivo => estado;

  /// Tolerante a `id`/`_id` y a `estado`/`activo`.
  factory Sede.fromJson(Map<String, dynamic> json) {
    final rawEstado = json['estado'] ?? json['activo'];
    final estado = rawEstado is bool
        ? rawEstado
        : (rawEstado?.toString().toLowerCase() == 'true' || rawEstado == null);

    return Sede(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nombre: json['nombre']?.toString() ?? '',
      ciudad: json['ciudad']?.toString() ?? '',
      barrio: json['barrio']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      estado: estado,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'ciudad': ciudad,
    'barrio': barrio,
    'direccion': direccion,
    'telefono': telefono,
    'estado': estado,
  };
}
