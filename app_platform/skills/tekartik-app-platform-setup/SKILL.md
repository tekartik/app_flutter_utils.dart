---
name: tekartik-app-platform-setup
description: >-
  Use when a Flutter app must know or initialize its platform with
  tekartik_app_platform: platformInit() at the start of main (Linux/Windows
  support), the platformContext getter and its PlatformContext (io, node,
  browser, platform, toMap) from package:tekartik_app_platform/app_platform.dart,
  and the isIOS / isAndroid / isLinux / isWindows / isMacOS / isWeb booleans of
  package:tekartik_app_platform/platform.dart (import with a prefix in
  flutter_test files).
---

# Platform helper (tekartik_app_platform)

`tekartik_app_platform` gives a Flutter app one conditional-import free way to
know where it runs: `platformInit()` to call at the start of `main()`, and a
`platformContext` describing the host (io, node or browser). It wraps
`tekartik_platform_io` and `tekartik_platform_browser` behind a stub/web/io
conditional export, so the same code compiles for mobile, desktop and web.

## Guidelines

* The package is not on pub.dev, depend on it from git:

  ```yaml
  dependencies:
    tekartik_app_platform:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_platform
      version: '>=0.1.0'
  ```

* Two libraries, and they serve different needs:
  * `package:tekartik_app_platform/app_platform.dart`: `platformInit()`,
    `platformContext` and the re-exported `PlatformContext` type. This is the
    one to import in `main.dart` and in shared code.
  * `package:tekartik_app_platform/platform.dart`: the lazy booleans
    `isIOS`, `isAndroid`, `isLinux`, `isWindows`, `isMacOS`, `isWeb`.
* Call `platformInit()` once, first thing in `main()`, before `runApp()` (it
  is what the tekartik example apps do). It is a no-op on web and mobile and
  handles the Linux/Windows desktop setup; calling it is harmless everywhere.
* `platformContext` is a `PlatformContext` (from
  `package:tekartik_platform/context.dart`, re-exported here):
  * `io` is non null on the Dart VM (Flutter mobile/desktop):
    `isAndroid`, `isIOS`, `isLinux`, `isMacOS`, `isWindows`, `environment`.
  * `browser` is non null on the web: `isChrome`, `isFirefox`, `isSafari`,
    `isChromeEdge`, `isIe`, `isMobile`, `version`, `os`, `device`.
  * `node` is non null on node.js, `platform` is the common io/node part.
  * `toMap()` returns a debug map (handy with `jsonPretty` from
    `package:tekartik_common_utils/common_utils_import.dart`).
* Always null-guard the context accessors, they are the platform test:
  `platformContext.io?.isAndroid ?? false`, `platformContext.browser != null`.
  Never assume `io` is non null in code that also builds for the web.
* The booleans of `platform.dart` are exactly those guarded expressions as
  top level `final`s, so they are safe (`false`) on the other platform.
  `isWeb` is `platformContext.browser != null`.
* `platform.dart` clashes with `flutter_test`, which also defines `isLinux`,
  `isMacOS`, `isWindows` and `isBrowser`: in a test file import it with a
  prefix (`import 'package:tekartik_app_platform/platform.dart' as p;`) as
  the package's own tests do. Same advice in any file that already imports
  `dart:io` `Platform` or `flutter/foundation.dart`.
* Do not import `package:tekartik_app_platform/src/...` (`platform_io.dart`,
  `platform_web.dart`, `platform_stub.dart`): the conditional export in
  `src/platform.dart` already picks the right one, and the stub throws
  `UnimplementedError`.
* In a pure Dart (non Flutter) program use `tekartik_platform_io` /
  `tekartik_platform_browser` directly: this package depends on the Flutter
  SDK.
* Runtime platform (`platformContext`) is not the same as the Flutter
  `TargetPlatform`/`defaultTargetPlatform` used for theming; use this package
  for capabilities (file system, process, browser), Flutter's for look and
  feel.

## Examples

### App entry point

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_platform/app_platform.dart';

void main() {
  // Linux/Windows support, no-op on web and mobile.
  platformInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Platform')),
        body: Center(child: Text(platformContext.toMap().toString())),
      ),
    );
  }
}
```

### Branching on the host

```dart
import 'package:tekartik_app_platform/app_platform.dart';

/// Where the app can write files, null on the web.
String? defaultDataPath() {
  var io = platformContext.io;
  if (io == null) {
    // Web (or node): no file system, use an indexed db based storage.
    return null;
  }
  if (io.isAndroid || io.isIOS) {
    return '.'; // Provided by path_provider in a real app.
  }
  return io.environment['HOME'] ?? '.';
}

bool get isDesktop {
  var io = platformContext.io;
  return io != null && (io.isLinux || io.isMacOS || io.isWindows);
}

bool get isMobileBrowser => platformContext.browser?.isMobile ?? false;
```

### The boolean helpers

```dart
import 'package:tekartik_app_platform/platform.dart';

String platformName() {
  if (isWeb) {
    return 'web';
  } else if (isAndroid) {
    return 'android';
  } else if (isIOS) {
    return 'ios';
  } else if (isLinux) {
    return 'linux';
  } else if (isMacOS) {
    return 'macos';
  } else if (isWindows) {
    return 'windows';
  }
  return 'unknown';
}
```

### Test file (prefixed import to avoid the flutter_test clash)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_platform/platform.dart' as p;

void main() {
  test('platform context', () {
    expect(platformContext, isNotNull);
    // flutter_test's isLinux/isMacOS/isWindows/isBrowser, unprefixed.
    expect(p.isLinux, isLinux);
    expect(p.isWeb, isBrowser);
    // Never true in a flutter test.
    expect(p.isAndroid, isFalse);
    expect(p.isIOS, isFalse);
  });
}
```
