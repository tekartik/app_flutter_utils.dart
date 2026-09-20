---
name: tekartik-app-flutter-common-web-utils-setup
description: >-
  Use when a Flutter app that also targets the web needs path URLs (no #) or
  must hide and show the mouse cursor (kiosk, TV, projector screens) from
  code shared with mobile and desktop, with
  tekartik_app_flutter_common_web_utils: webUsePathUrlStrategy,
  webUseHashUrlStrategy, setPathUrlStrategy, setHashUrlStrategy
  (url_strategy.dart), hideCursor, showCursor (cursor_utils.dart), all safe
  no-ops off the web.
---

# Flutter web helpers callable from shared code (tekartik_app_flutter_common_web_utils)

Two tiny libraries whose web implementation is selected by conditional
import: they do their job when compiled for the browser and are no-ops on
mobile and desktop, so `main()` and shared widgets call them without `kIsWeb`
checks and without importing `flutter_web_plugins` or `package:web`
themselves.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_common_web_utils:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_common_web
  ```
* URL strategy, `package:tekartik_app_flutter_common_web_utils/url_strategy.dart`:
  `webUsePathUrlStrategy()` switches the web app from `/#/settings` to
  `/settings` URLs (it calls `usePathUrlStrategy()` from
  `flutter_web_plugins`). Call it in `main()` before `runApp`, before any
  router reads the initial location. `setPathUrlStrategy()` is the older
  alias. The hosting server must then serve `index.html` for every path
  (Firebase Hosting rewrites, the `flutter run` dev server does).
* Hash URLs are Flutter's default: to keep them, call nothing. In the current
  source `webUseHashUrlStrategy()` / `setHashUrlStrategy()` are placeholders
  whose web implementation also calls `usePathUrlStrategy()`; do not rely on
  them to restore hash URLs.
* Cursor, `package:tekartik_app_flutter_common_web_utils/cursor_utils.dart`:
  `hideCursor()` and `showCursor()` return `Future<void>`. On the web they
  write `cursor: none;` or `cursor: default;` into the `style` attribute of
  the `<flutter-view>` element and start (once) a background loop that
  re-applies the requested state every second, because the Flutter engine
  rewrites that style on pointer changes. The state is global for the page.
* Typical use: `hideCursor()` in `initState` of a full-screen TV/kiosk page,
  `showCursor()` in its `dispose` or when leaving the mode. Do not call them
  from `build`. `unawaited(...)` them (they resolve immediately).
* Off the web everything is a no-op, so the package's tests pass on the VM;
  verify the behaviour in a browser (`flutter run -d chrome`). There is no
  API to stop the background loop; leaving the cursor on `showCursor()` is
  the neutral state.

## Examples

### Path URLs on the web, no-op elsewhere

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_web_utils/url_strategy.dart';

void main() {
  // Before runApp: /#/settings becomes /settings in the browser.
  webUsePathUrlStrategy();
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => const Scaffold(body: Center(child: Text('home'))),
        '/settings': (_) => const Scaffold(body: Center(child: Text('settings'))),
      },
    ),
  );
}
```

### A TV screen that hides the cursor while shown

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_web_utils/cursor_utils.dart';

class TvScreen extends StatefulWidget {
  const TvScreen({super.key});

  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(hideCursor());
  }

  @override
  void dispose() {
    unawaited(showCursor());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text('Now playing', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: TvScreen()));
}
```

### Toggle from a button (menu or settings page)

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_web_utils/cursor_utils.dart';

class CursorButtons extends StatelessWidget {
  const CursorButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () async {
            await hideCursor();
          },
          child: const Text('Hide cursor'),
        ),
        ElevatedButton(
          onPressed: () async {
            await showCursor();
          },
          child: const Text('Show cursor'),
        ),
      ],
    );
  }
}
```
