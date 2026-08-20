import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Permite definir la URL del backend al compilar, especialmente para un
  /// celular físico: --dart-define=API_BASE_URL=http://192.168.x.x:3000
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;

    if (kIsWeb) {
      return 'https://api-unistock.onrender.com';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    return 'https://api-unistock.onrender.com';
  }
}
