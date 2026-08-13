import 'package:movil_unistock/core/api_client.dart';
import 'product.dart';

class ProductService {
  ProductService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<Product>> getProducts() async {
    final data = await _client.get('/products');
    return _asList(data)
        .map((item) => Product.fromJson(_asMap(item)))
        .toList();
  }

  List<dynamic> _asList(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map && data['data'] is List<dynamic>) {
      return data['data'] as List<dynamic>;
    }
    throw Exception('Respuesta inesperada del servidor: se esperaba una lista');
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Respuesta inesperada del servidor: se esperaba un producto');
  }

  Future<Product> createProduct({
    required String categoryId,
    required String referencia,
    required String nombre,
    required double precio,
    required int stock,
  }) async {
    final data = await _client.post(
      '/products',
      {
        'idCategoria': categoryId,
        'id_categorias': categoryId,
        'referencia': referencia,
        'nombre': nombre,
        'precio': precio,
        'stock': stock,
        'imagenesUrl': [],
        'ficha_tecnica': {
          'responsable': 'Móvil',
          'fecha_inicio': DateTime.now().toIso8601String().split('T').first,
          'fecha_fin': DateTime.now().toIso8601String().split('T').first,
          'versiones': 1,
          'descripciones': 'Ficha técnica creada desde móvil',
          'materiales': [],
        },
      },
    );
    return Product.fromJson(_asProductMap(data));
  }

  Map<String, dynamic> _asProductMap(dynamic data) {
    final map = _asMap(data);
    if (map['product'] is Map) return _asMap(map['product']);
    return map;
  }

  Future<Product> updateProduct({
    required String id,
    String? categoryId,
    String? referencia,
    String? nombre,
    double? precio,
    int? stock,
  }) async {
    final data = await _client.put(
      '/products/$id',
      {
        if (categoryId != null) 'id_categorias': categoryId,
        if (referencia != null) 'referencia': referencia,
        if (nombre != null) 'nombre': nombre,
        if (precio != null) 'precio': precio,
        if (stock != null) 'stock': stock,
      },
    );
    return Product.fromJson(_asProductMap(data));
  }

  Future<void> deleteProduct(String id) async {
    await _client.delete('/products/$id');
  }

  Future<Product> toggleProductStatus(String id, bool estado) async {
    final data = await _client.patch('/products/$id/status', {'estado': estado});
    return Product.fromJson(_asProductMap(data));
  }
}
