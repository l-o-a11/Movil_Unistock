import 'package:http/http.dart' as http;

class ApiClient {
  static const List<String> _defaultBaseUrls = [
    'http://127.0.0.1:3000',
    'http://localhost:3000',
    'http://127.0.0.1:3020',
    'http://localhost:3020',
    'http://127.0.0.1:3001',
    'http://localhost:3001',
    'https://api-unistock.onrender.com',
  ];

  final List<String> baseUrls;

  ApiClient({List<String>? baseUrls}) : baseUrls = baseUrls ?? _defaultBaseUrls;

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _send(endpoint, (uri) => http.get(uri, headers: headers));
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _send(endpoint, (uri) => http.post(uri, headers: headers, body: body));
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _send(endpoint, (uri) => http.put(uri, headers: headers, body: body));
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _send(endpoint, (uri) => http.patch(uri, headers: headers, body: body));
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _send(endpoint, (uri) => http.delete(uri, headers: headers));
  }

  Future<http.Response> _send(
    String endpoint,
    Future<http.Response> Function(Uri uri) action,
  ) async {
    http.Response? lastResponse;
    Object? lastError;

    for (final baseUrl in baseUrls) {
      final uri = Uri.parse('$baseUrl$endpoint');
      try {
        final response = await action(uri);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        lastResponse = response;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastResponse != null) {
      return lastResponse;
    }

    throw Exception('No se pudo conectar a la API en ${baseUrls.join(', ')}. ${lastError ?? 'Sin respuesta.'}');
  }
}
