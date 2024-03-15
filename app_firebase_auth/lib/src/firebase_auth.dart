// ignore: depend_on_referenced_packages
export 'package:tekartik_firebase_auth/auth.dart';

export 'firebase_auth_stub.dart'
    if (dart.library.js_interop) 'firebase_auth_web.dart'
    if (dart.library.io) 'firebase_auth_io.dart';
