class ProductCategory {
  final String id;
  final String nombre;
  final String descripcion;
  final bool estado;
  final int cantidadProductos;
  final int productosDisponibles;

  const ProductCategory({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    this.cantidadProductos = 0,
    this.productosDisponibles = 0,
  });

  String get estadoLabel => estado ? 'Activo' : 'Inactivo';
  bool get isActivo => estado;

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        nombre: json['nombre']?.toString() ?? '',
        descripcion: json['descripcion']?.toString() ??
            json['description']?.toString() ??
            '',
        estado: json['estado'] as bool? ?? false,
        cantidadProductos: (json['cantidad_productos'] as num?)?.toInt() ?? 0,
        productosDisponibles:
            (json['productos_disponibles'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'estado': estado,
        'cantidad_productos': cantidadProductos,
        'productos_disponibles': productosDisponibles,
      };
}
