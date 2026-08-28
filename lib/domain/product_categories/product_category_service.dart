import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movil_unistock/config/api_config.dart';
import 'package:movil_unistock/shared/services/auth_service.dart';
import 'product_category.dart';

class ProductCategoryService {
  final String baseUrl;
  final String _resource = 'product-categories';
  final AuthService _auth;

  ProductCategoryService({String? baseUrl, AuthService? auth})
      : baseUrl = baseUrl ?? '${ApiConfig.baseUrl}/api',
        _auth = auth ?? AuthService();

  Future<List<ProductCategory>> getCategories() async {
    final uri = Uri.parse('$baseUrl/$_resource');
    final response = await http
        .get(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = _extractDataList(body);
      return data.map((e) => ProductCategory.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('No se pudieron cargar las categorías (${response.statusCode})');
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
    final uri = Uri.parse('$baseUrl/$_resource');
    final response = await http
        .post(uri, headers: await _authHeaders, body: jsonEncode({'nombre': nombre, 'descripcion': descripcion}))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ProductCategory.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception('No se pudo crear la categoría (${response.statusCode})');
  }

  Future<ProductCategory> updateCategory({required String id, String? nombre, String? descripcion}) async {
    final uri = Uri.parse('$baseUrl/$_resource/$id');
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (descripcion != null) body['descripcion'] = descripcion;

    final response = await http
        .put(uri, headers: await _authHeaders, body: jsonEncode(body))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final respBody = jsonDecode(response.body) as Map<String, dynamic>;
      return ProductCategory.fromJson(respBody['data'] as Map<String, dynamic>);
    }
    throw Exception('No se pudo actualizar la categoría (${response.statusCode})');
  }

  Future<void> deleteCategory(String id) async {
    final uri = Uri.parse('$baseUrl/$_resource/$id');
    final response = await http
        .delete(uri, headers: await _authHeaders)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('No se pudo eliminar la categoría (${response.statusCode})');
    }
  }

  Future<ProductCategory> toggleCategoryStatus(String id, bool estado) async {
    final uri = Uri.parse('$baseUrl/$_resource/$id');
    final response = await http
        .put(uri, headers: await _authHeaders, body: jsonEncode({'estado': estado}))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ProductCategory.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception('No se pudo cambiar el estado (${response.statusCode})');
  }

  Future<Map<String, String>> get _authHeaders async {
    final token = await _auth.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
