class Sede {
  final int id;
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

  factory Sede.fromJson(Map<String, dynamic> json) => Sede(
    id: json['id'] as int,
    nombre: json['nombre']?.toString() ?? '',
    ciudad: json['ciudad']?.toString() ?? '',
    barrio: json['barrio']?.toString() ?? '',
    direccion: json['direccion']?.toString() ?? '',
    telefono: json['telefono']?.toString() ?? '',
    estado: json['estado'] as bool? ?? false,
  );

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
