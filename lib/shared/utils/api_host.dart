import 'api_host_stub.dart'
    if (dart.library.io) 'api_host_io.dart'
    if (dart.library.html) 'api_host_web.dart';

String get apiHost => getApiHost();
