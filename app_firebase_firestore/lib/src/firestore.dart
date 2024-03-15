export 'firestore_stub.dart'
    if (dart.library.js_interop) 'firestore_web.dart'
    if (dart.library.io) 'firestore_io.dart';
