/// Platform full screen: the browser full screen api on the web, the window
/// manager on Linux, macOS and Windows, the immersive system ui mode on
/// Android and iOS, behind one [PlatformFullScreen] interface.
///
/// This is only the extra "take over the screen" step, which may be
/// unsupported or refused. An app's own full screen (hide its chrome) works
/// everywhere and never needs it.
library;

export 'src/full_screen.dart'
    show PlatformFullScreen, PlatformFullScreenBase, PlatformFullScreenOptions;
export 'src/full_screen_factory.dart' show createPlatformFullScreen;
