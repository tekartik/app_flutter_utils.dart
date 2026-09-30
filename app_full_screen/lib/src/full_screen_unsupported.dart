import 'full_screen.dart';

/// No platform full screen.
PlatformFullScreen createPlatformFullScreen({
  PlatformFullScreenOptions? options,
}) => PlatformFullScreenUnsupported();

/// Never full screen, every request ignored.
class PlatformFullScreenUnsupported extends PlatformFullScreenBase {
  @override
  bool get supported => false;

  @override
  Future<void> setFullScreen(bool fullScreen) async {}
}
