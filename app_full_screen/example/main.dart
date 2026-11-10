// A player page: tap to toggle the platform full screen (the browser full
// screen on the web, the app window on desktop, the immersive mode on
// mobile). Widgets only, a Material app does the same with an IconButton.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';

void main() {
  runApp(const PlayerPage());
}

/// A page that can take over the screen.
class PlayerPage extends StatefulWidget {
  /// Injected in tests (`PlatformFullScreenMemory`), created otherwise.
  final PlatformFullScreen? fullScreen;

  /// A page that can take over the screen.
  const PlayerPage({super.key, this.fullScreen});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final PlatformFullScreen _fullScreen;
  late final bool _ownsFullScreen;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _ownsFullScreen = widget.fullScreen == null;
    _fullScreen = widget.fullScreen ?? createPlatformFullScreen();
    // Escape in the browser, F11 on desktop: rebuild.
    _subscription = _fullScreen.onChanged.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_ownsFullScreen) {
      // Leaving the page leaves full screen (dispose alone does not).
      if (_fullScreen.isFullScreen) {
        unawaited(_fullScreen.setFullScreen(false));
      }
      _fullScreen.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var text = !_fullScreen.supported
        ? 'Full screen not supported'
        : (_fullScreen.isFullScreen
              ? 'Full screen, tap to leave'
              : 'Tap for full screen');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Synchronous, straight from the gesture (the browser requires it).
      onTap: _fullScreen.supported ? _fullScreen.toggleFullScreen : null,
      child: Center(child: Text(text, textDirection: TextDirection.ltr)),
    );
  }
}
