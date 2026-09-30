---
name: tekartik-app-flutter-full-screen-setup
description: >-
  Use when a Flutter app must take over the whole screen (a player, a kiosk, a
  slideshow) on the web, desktop and mobile with
  tekartik_app_flutter_full_screen: createPlatformFullScreen() from
  package:tekartik_app_flutter_full_screen/full_screen.dart and its
  PlatformFullScreen (supported, isFullScreen, onChanged, setFullScreen,
  toggleFullScreen, dispose), the browser full screen api / window_manager /
  SystemChrome immersive mode behind it, PlatformFullScreenOptions for the
  mobile system ui modes, and PlatformFullScreenMemory from
  full_screen_memory.dart for widget tests.
---

# Platform full screen (tekartik_app_flutter_full_screen)

One interface to ask the platform for full screen: the browser full screen api
on the web (through `tekartik_browser_utils`), `window_manager` on Linux, macOS
and Windows, `SystemChrome.setEnabledSystemUIMode` on Android and iOS,
unsupported elsewhere. Extracted from the playelio karaoke player.

## Guidelines

* The package is not on pub.dev, depend on it from git:

  ```yaml
  dependencies:
    tekartik_app_flutter_full_screen:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_full_screen
      version: '>=0.1.0'
  ```

* Two libraries:
  * `package:tekartik_app_flutter_full_screen/full_screen.dart`:
    `createPlatformFullScreen({PlatformFullScreenOptions? options})`, the
    `PlatformFullScreen` interface, `PlatformFullScreenOptions` and the
    `PlatformFullScreenBase` class for custom implementations.
  * `package:tekartik_app_flutter_full_screen/full_screen_memory.dart`:
    `PlatformFullScreenMemory`, the in-memory implementation for tests.
  Never import `lib/src/`.
* **This is only the platform step.** An app's own full screen (hide the app
  bar and the controls, keep only the player) works everywhere and needs no
  plugin. Do it with the app state, and call `setFullScreen` in addition, as
  the extra "take over the screen" step that may be unsupported or refused.
* **A refusal is not an error.** `setFullScreen` never throws: the browser
  refuses outside a user gesture, the plugin is missing in `flutter test`,
  the platform is unsupported. The state simply does not change; read
  `isFullScreen` after the call when it matters.
* **Call it synchronously from the gesture on the web**: straight from
  `onPressed`, before any `await`. A request made later from an async
  continuation is refused by the browser.
* **Listen to `onChanged`** to follow changes not asked for: escape or F11 in
  the browser, the window manager on desktop. `isFullScreen` is the truth
  (`document.fullscreenElement` on the web), the stream fires only when it
  changes. Rebuild the widget from it, do not assume the last request stuck.
* **One instance per screen**, created after the widgets binding is
  initialized (in `initState`, or in `main` after
  `WidgetsFlutterBinding.ensureInitialized()`), and `dispose()`d in
  `State.dispose`: it holds a platform listener and closes `onChanged`.
  Leaving full screen on dispose is the app's decision (`setFullScreen(false)`
  before `dispose()`).
* `supported` is false on unsupported platforms and in a browser page that
  forbids full screen (an iframe without `allowfullscreen`); hide the button
  then. True on desktop and mobile even when the plugin is missing.
* Mobile modes: `PlatformFullScreenOptions(mobileFullScreenMode:
  SystemUiMode.immersiveSticky, mobileNormalMode: SystemUiMode.edgeToEdge)`
  are the defaults; leaving full screen restores `mobileNormalMode`, not the
  mode the app had before (there is no way to read it). Pass the app's own
  mode when it is not edge to edge. `SystemUiMode.manual` is not supported.
* Desktop needs `window_manager` in the app's platform runners (Linux, macOS,
  Windows): a plain `flutter create` app has it once the package is a
  dependency. No extra configuration on the web or mobile.
* On the web the whole document goes full screen, unless the page has an
  element with id `tekartik_full_screen_section` (then that element does).
* Tests: use `PlatformFullScreenMemory` and inject it into the widget; it
  records every request in `requests` and `simulateFullScreenChanged(bool)`
  plays an escape. The real implementation is safe in `flutter test` (the
  requests are refused) but proves nothing.

## Examples

### A player page with a full screen button

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';

class PlayerPage extends StatefulWidget {
  /// Injected in tests (PlatformFullScreenMemory), created otherwise.
  final PlatformFullScreen? fullScreen;

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
    // Escape in the browser, the window manager: rebuild.
    _subscription = _fullScreen.onChanged.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_ownsFullScreen) {
      _fullScreen.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isFullScreen = _fullScreen.isFullScreen;
    return Scaffold(
      // The app's own full screen: no app bar while the platform is full
      // screen.
      appBar: isFullScreen ? null : AppBar(title: const Text('Player')),
      body: const Center(child: Text('Video')),
      floatingActionButton: _fullScreen.supported
          ? FloatingActionButton(
              // Synchronous, straight from the gesture (web).
              onPressed: () => _fullScreen.toggleFullScreen(),
              child: Icon(
                isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              ),
            )
          : null,
    );
  }
}
```

### Custom mobile modes

```dart
import 'package:flutter/services.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';

/// An app that already runs lean back restores lean back when leaving.
PlatformFullScreen createLeanBackFullScreen() => createPlatformFullScreen(
  options: const PlatformFullScreenOptions(
    mobileFullScreenMode: SystemUiMode.immersive,
    mobileNormalMode: SystemUiMode.leanBack,
  ),
);
```

### Widget test with the memory implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen_memory.dart';

void main() {
  testWidgets('toggle', (tester) async {
    var fullScreen = PlatformFullScreenMemory();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextButton(
            onPressed: () => fullScreen.toggleFullScreen(),
            child: const Text('toggle'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('toggle'));
    await tester.pump();
    expect(fullScreen.isFullScreen, isTrue);
    expect(fullScreen.requests, [true]);

    // Escape in the browser.
    fullScreen.simulateFullScreenChanged(false);
    expect(fullScreen.isFullScreen, isFalse);
    fullScreen.dispose();
  });
}
```
