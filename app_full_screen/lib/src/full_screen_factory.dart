export 'full_screen_unsupported.dart'
    if (dart.library.js_interop) 'full_screen_web.dart'
    if (dart.library.io) 'full_screen_io.dart'
    show createPlatformFullScreen;
