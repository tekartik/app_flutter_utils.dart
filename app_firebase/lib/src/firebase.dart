export 'package:tekartik_firebase/firebase.dart'; // ignore: depend_on_referenced_packages

export 'firebase_stub.dart'
    if (dart.library.js_interop) 'firebase_web.dart'
    if (dart.library.io) 'firebase_io.dart';
