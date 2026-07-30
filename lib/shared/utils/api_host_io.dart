import 'dart:io';

String getApiHost() {
  if (Platform.isAndroid) {
    return '10.0.2.2';
  }

  return 'localhost';
}
