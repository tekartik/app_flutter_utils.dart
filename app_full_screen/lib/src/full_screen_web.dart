import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tekartik_browser_utils/full_screen_utils.dart' as browser;

import 'full_screen.dart';

/// The browser full screen api.
PlatformFullScreen createPlatformFullScreen({
  PlatformFullScreenOptions? options,
}) => PlatformFullScreenWeb();

/// Web implementation on `tekartik_browser_utils`: `document.fullscreenElement`
/// is the truth, `fullscreenchange` the only way to hear about escape.
class PlatformFullScreenWeb extends PlatformFullScreenBase {
  StreamSubscription<bool>? _subscription;

  /// Starts listening to the document full screen changes.
  PlatformFullScreenWeb() {
    _subscription = browser.onFullScreenChange.listen(setFullScreenState);
  }

  @override
  bool get supported => browser.isFullScreenSupported();

  @override
  bool get isFullScreen => browser.isFullScreen();

  @override
  Future<void> setFullScreen(bool fullScreen) async {
    try {
      if (fullScreen) {
        if (!isFullScreen) {
          await browser.requestFullScreen();
        }
      } else {
        await browser.exitFullScreen();
      }
    } catch (e) {
      // Typically refused when not called from a user gesture.
      debugPrint('full screen: $e');
    }
    setFullScreenState(isFullScreen);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
