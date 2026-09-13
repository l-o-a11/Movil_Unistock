class Categoria {
  final String id;
  final String nombre;
  final bool estado;

  const Categoria({
    required this.id,
    required this.nombre,
    required this.estado,
  });

  String get estadoLabel => estado ? 'Activo' : 'Inactivo';
  bool get isActivo => estado;

  /// Tolerante a `id`/`_id` y a `estado`/`activo`.
  factory Categoria.fromJson(Map<String, dynamic> json) {
    final rawEstado = json['estado'] ?? json['activo'];
    final estado = rawEstado is bool
        ? rawEstado
        : (rawEstado?.toString().toLowerCase() == 'true' || rawEstado == null);

    return Categoria(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nombre: json['nombre']?.toString() ?? '',
      estado: estado,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'estado': estado,
  };
}
