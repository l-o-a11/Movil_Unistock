class Categoria {
  final int id;
  final String nombre;
  final bool estado;

  const Categoria({
    required this.id,
    required this.nombre,
    required this.estado,
  });

  String get estadoLabel => estado ? 'Activo' : 'Inactivo';
  bool get isActivo => estado;

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
    id: json['id'] as int,
    nombre: json['nombre']?.toString() ?? '',
    estado: json['estado'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'estado': estado,
  };
}
