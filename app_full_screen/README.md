# tekartik_app_flutter_utils/app_full_screen

Take over the screen from a Flutter app, the same way everywhere: the browser
full screen api on the web, the window manager on Linux, macOS and Windows, the
immersive system ui mode on Android and iOS.

This is only the extra "platform" step. An app's own full screen (hide its
chrome, show only the player) works everywhere and never needs it; the platform
step may be unsupported or refused (the browser refuses outside a user gesture),
and a refusal is not an error: the state simply does not change.

## Setup

```yaml
dependencies:
  tekartik_app_flutter_full_screen:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_full_screen
    version: '>=0.1.0'
```

## Usage

```dart
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';

// One per screen that needs it, created after the widgets binding is ready
// (i.e. from a State), disposed with it.
final fullScreen = createPlatformFullScreen();

// From a user gesture (the browser refuses otherwise).
await fullScreen.setFullScreen(true);
await fullScreen.toggleFullScreen();

// Changes not asked for too (escape in the browser, the window manager).
fullScreen.onChanged.listen((isFullScreen) => setState(() {}));

fullScreen.dispose();
```

`PlatformFullScreenMemory` (`full_screen_memory.dart`) is an in-memory
implementation for tests and previews.
