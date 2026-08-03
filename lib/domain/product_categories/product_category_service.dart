import 'dart:convert';
import 'package:movil_unistock/shared/utils/api_client.dart';
import 'product_category.dart';

class ProductCategoryService {
  final ApiClient _client = ApiClient();

  Future<List<ProductCategory>> getCategories() async {
    final response = await _client.get(
      '/api/product-categories',
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las categorías (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = _extractDataList(body);
    return data.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>)).toList();
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

  Future<ProductCategory> createCategory({required String nombre, required String descripcion}) async {
    final response = await _client.post(
      '/api/product-categories',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nombre': nombre, 'descripcion': descripcion}),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo crear la categoría');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductCategory.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<ProductCategory> updateCategory({required String id, String? nombre, String? descripcion}) async {
    final response = await _client.put(
      '/api/product-categories/$id',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (nombre != null) 'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo actualizar la categoría');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductCategory.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCategory(String id) async {
    final response = await _client.delete('/api/product-categories/$id');
    if (response.statusCode != 200) {
      throw Exception('No se pudo eliminar la categoría');
    }
  }

  Future<ProductCategory> toggleCategoryStatus(String id, bool estado) async {
    final response = await _client.put(
      '/api/product-categories/$id',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'estado': estado}),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo cambiar el estado');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductCategory.fromJson(body['data'] as Map<String, dynamic>);
  }
}
