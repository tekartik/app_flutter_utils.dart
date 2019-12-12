export 'web_socket_stub.dart'
    if (dart.library.html) 'web_socket_web.dart'
    if (dart.library.io) 'web_socket_io.dart';
