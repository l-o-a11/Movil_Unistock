class ApiConfig {
  /// Permite apuntar a otro backend al compilar — típicamente para probar
  /// contra tu máquina local: --dart-define=API_BASE_URL=http://10.0.2.2:3000
  /// (Android) o --dart-define=API_BASE_URL=http://192.168.x.x:3000
  /// (celular físico en la misma red WiFi).
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  // FIX: antes Android usaba 10.0.2.2 (backend LOCAL) por defecto y solo
  // Web/iOS apuntaban al backend desplegado en Render. Como el backend ya
  // está desplegado, ahora TODAS las plataformas usan esa URL por defecto
  // — local solo se usa si lo pides explícitamente con --dart-define.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    return 'https://api-unistock.onrender.com';
  }
}
