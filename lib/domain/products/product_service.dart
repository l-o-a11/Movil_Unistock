import 'dart:convert';
import 'package:movil_unistock/shared/utils/api_client.dart';
import 'product.dart';

class ProductService {
  final ApiClient _client = ApiClient();

  Future<List<Product>> getProducts() async {
    final response = await _client.get(
      '/api/products',
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los productos (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = _extractDataList(body);
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  List<dynamic> _extractDataList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      return data['data'] as List<dynamic>;
    }
    throw Exception('Respuesta inesperada del servidor: data debe ser una lista');
  }

  Future<Product> createProduct({
    required String categoryId,
    required String referencia,
    required String nombre,
    required double precio,
    required int stock,
  }) async {
    final response = await _client.post(
      '/api/products',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo crear el producto');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return Product.fromJson(data);
    }
    if (data is Map) {
      final product = data['product'];
      if (product is Map<String, dynamic>) {
        return Product.fromJson(product);
      }
    }
    throw Exception('Respuesta inesperada del servidor');
  }

  Future<Product> updateProduct({
    required String id,
    String? categoryId,
    String? referencia,
    String? nombre,
    double? precio,
    int? stock,
  }) async {
    final response = await _client.put(
      '/api/products/$id',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (categoryId != null) 'id_categorias': categoryId,
        if (referencia != null) 'referencia': referencia,
        if (nombre != null) 'nombre': nombre,
        if (precio != null) 'precio': precio,
        if (stock != null) 'stock': stock,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo actualizar el producto');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    final response = await _client.delete('/api/products/$id');
    if (response.statusCode != 200) {
      throw Exception('No se pudo eliminar el producto');
    }
  }

  Future<Product> toggleProductStatus(String id, bool estado) async {
    final response = await _client.patch('/api/products/$id/status');

    if (response.statusCode != 200) {
      throw Exception('No se pudo cambiar el estado');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(body['data'] as Map<String, dynamic>);
  }
}
