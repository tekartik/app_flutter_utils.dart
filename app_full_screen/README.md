# tekartik_app_flutter_full_screen

Take over the screen from a Flutter app, the same way everywhere: the browser
full screen api on the web, the app window
([tekartik_app_flutter_window](../app_window/README.md)) on Linux, macOS and
Windows, the immersive system ui mode on Android and iOS, behind one
`PlatformFullScreen` interface.

This is only the extra "platform" step. An app's own full screen (hide its
chrome, show only the player) works everywhere and never needs it; the
platform step may be unsupported or refused (the browser refuses outside a
user gesture), and a refusal is not an error: the state simply does not
change.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_full_screen:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_full_screen
```

One instance per screen that needs it, created in `initState`, disposed with
the state:

```dart
import 'dart:async';

import 'package:material_ui/material_ui.dart'; // or flutter/material.dart
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final _fullScreen = createPlatformFullScreen();
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    // Changes not asked for too: escape in the browser, F11.
    _subscription = _fullScreen.onChanged.listen((_) => setState(() {}));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _fullScreen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isFullScreen = _fullScreen.isFullScreen;
    return Scaffold(
      appBar: isFullScreen ? null : AppBar(title: const Text('Player')),
      body: const Center(child: Text('Video')),
      floatingActionButton: _fullScreen.supported
          ? FloatingActionButton(
              // Straight from the gesture (the browser requires it).
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

Complete app in [example/main.dart](example/main.dart).

## Platforms

| Platform | Full screen | `isFullScreen` | Changes heard |
|---|---|---|---|
| Web | `requestFullscreen` on the element of id `tekartik_full_screen_section`, else the document | `document.fullscreenElement` | escape, the browser |
| Linux, macOS, Windows | the app window (window_manager >= 0.6.0) | the window state when created, then its events | F11, the title bar button |
| Android, iOS | `SystemChrome.setEnabledSystemUIMode` (`immersiveSticky`, `edgeToEdge` to leave) | the last request | none |
| `flutter test` | refused (no window, no plugin) | false | none |

Linux build machines need `libgtk-3-dev libx11-dev libxi-dev` (the native
core of window_manager is built by a build hook).

## Common pitfalls

- Call `setFullScreen` / `toggleFullScreen` synchronously from the gesture
  (`onPressed`), before any `await`: the browser refuses a later request.
- `dispose()` does not leave full screen: call `setFullScreen(false)` first
  when the screen should not stay full screen.
- An instance created while the platform is already full screen (left so by
  another screen) starts full screen on the web and desktop, and reports the
  exit (fixed 2026-11-10: it started at false and missed the escape or F11).
- Mobile: the system ui mode cannot be read back. Leaving full screen applies
  `mobileNormalMode` (`edgeToEdge` by default), not the mode the app had:
  pass it in `PlatformFullScreenOptions`. With `SystemUiMode.immersive` or
  `leanBack`, a swipe brings the bars back for good and `isFullScreen` stays
  true.

## Testing

`PlatformFullScreenMemory` (`full_screen_memory.dart`) records the requests
and `simulateFullScreenChanged(bool)` plays an escape; inject it into the
widget under test.

Agent skill:
[tekartik-app-flutter-full-screen-setup](skills/tekartik-app-flutter-full-screen-setup/SKILL.md).
