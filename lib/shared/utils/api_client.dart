import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class ApiClient {
  // FIX: antes probaba una lista fija de URLs locales (127.0.0.1,
  // localhost en varios puertos) y como último recurso la de Render —
  // eso significaba varios intentos fallidos (lentos) antes de conectar
  // de verdad contra el backend desplegado. Ahora usa SIEMPRE
  // ApiConfig.baseUrl, la misma fuente de verdad que el resto de la app.
  //
  // OJO: este archivo (lib/shared/utils/api_client.dart) es DISTINTO de
  // lib/core/api_client.dart — comparten nombre de archivo pero son dos
  // clases separadas. Esta versión (simple, sin sesión) la usa SOLO
  // product_category_service.dart. La versión con singleton/token/usuario
  // que usa el resto de la app vive en lib/core/api_client.dart — no se
  // deben mezclar entre sí.
  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? ApiConfig.baseUrl;

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
    return _send(
      endpoint,
      (uri) => http.post(uri, headers: headers, body: body),
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _send(
      endpoint,
      (uri) => http.put(uri, headers: headers, body: body),
    );
  }

  Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _send(
      endpoint,
      (uri) => http.patch(uri, headers: headers, body: body),
    );
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
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      return await action(uri);
    } catch (error) {
      throw Exception('No se pudo conectar a la API en $baseUrl. $error');
    }
  }
}
