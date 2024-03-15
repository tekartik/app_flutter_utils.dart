// ignore: depend_on_referenced_packages
export 'package:tekartik_prefs/prefs.dart';

export 'prefs_stub.dart'
    if (dart.library.js_interop) 'prefs_web.dart'
    if (dart.library.io) 'prefs_io.dart';
