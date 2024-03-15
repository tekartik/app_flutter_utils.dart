export 'storage_stub.dart'
    if (dart.library.js_interop) 'storage_web.dart'
    if (dart.library.io) 'storage_io.dart';
