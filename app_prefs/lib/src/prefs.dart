export 'package:tekartik_prefs/prefs.dart';

export 'prefs_stub.dart'
    if (dart.library.html) 'prefs_web.dart'
    if (dart.library.io) 'prefs_io.dart';
