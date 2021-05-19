export 'package:tekartik_firebase/firebase.dart';

export 'firebase_stub.dart'
    if (dart.library.html) 'firebase_web.dart'
    if (dart.library.io) 'firebase_io.dart';
