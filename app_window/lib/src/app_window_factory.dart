export 'app_window_unsupported.dart'
    if (dart.library.io) 'app_window_io.dart'
    show appWindowCurrent, appWindowSupported;
