class Product {
  final String id;
  final String categoryId;
  final String referencia;
  final String nombre;
  final double precio;
  final int stock;
  final bool estado;
  final List<String> imagenesUrl;

  const Product({
    required this.id,
    required this.categoryId,
    required this.referencia,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.estado,
    this.imagenesUrl = const [],
  });

  String get estadoLabel => estado ? 'Activo' : 'Inactivo';
  bool get isActivo => estado;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        referencia: json['referencia']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
        precio: (json['precio'] as num?)?.toDouble() ?? 0,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        estado: json['estado'] as bool? ?? false,
        categoryId: (json['id_categorias'] ?? json['idCategoria'] ?? '').toString(),
        imagenesUrl: _extractImageUrls(json),
      );

  static List<String> _extractImageUrls(Map<String, dynamic> json) {
    final urls = <String>[];

    final rawImageList = json['imagenes_Url'] ?? json['imagenesUrl'] ?? json['allImages'];

    if (rawImageList is List) {
      for (final item in rawImageList) {
        if (item is String && item.isNotEmpty) {
          urls.add(item);
        } else if (item is Map<String, dynamic>) {
          final src = item['src'] ?? item['url'] ?? item['secure_url'];
          if (src is String && src.isNotEmpty) {
            urls.add(src);
          }
        }
      }
    }

    return urls;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_categorias': categoryId,
        'referencia': referencia,
        'nombre': nombre,
        'precio': precio,
        'stock': stock,
        'estado': estado,
        'imagenes_Url': imagenesUrl,
      };
}
