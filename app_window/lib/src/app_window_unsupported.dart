import 'app_window.dart';

/// False: no app window to manage on this platform (the web).
bool get appWindowSupported => false;

/// Null: no app window to manage on this platform (the web).
AppWindow? appWindowCurrent() => null;
