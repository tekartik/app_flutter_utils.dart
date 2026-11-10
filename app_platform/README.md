# tekartik_app_platform

Where a Flutter app runs, with no conditional import in app code: a
`platformContext` (a `PlatformContext` of
[tekartik_platform](https://github.com/tekartik/platform.dart)) whose `io` is
set on Android, iOS, macOS, Linux and Windows and whose `browser` is set on
the web, plus `isAndroid`, `isIOS`, `isLinux`, `isMacOS`, `isWindows`,
`isWeb` booleans.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_platform:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_platform
```

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_platform/app_platform.dart';

void main() {
  var io = platformContext.io; // null on the web
  var browser = platformContext.browser; // null off the web
  var text = io != null
      ? 'io, android: ${io.isAndroid}'
      : 'web, chrome: ${browser?.isChrome}';
  runApp(Center(child: Text(text, textDirection: TextDirection.ltr)));
}
```

Complete app in [example/main.dart](example/main.dart).

## What to use

- `app_platform.dart`: `platformContext` (`io`, `browser`, `toMap()`) and
  `platformInit()`.
- `platform.dart`: the `final` booleans `isAndroid`, `isIOS`, `isLinux`,
  `isMacOS`, `isWindows` (false on the web), `isWeb`.

## Common pitfalls

- The booleans are about the runtime: on the web `isAndroid` is false even
  in Chrome on Android; use `platformContext.browser?.os.isAndroid` there.
- Import `platform.dart` with a prefix in test files
  (`import 'package:tekartik_app_platform/platform.dart' as p;`): its names
  clash with the test matchers.
- `platformInit()` does nothing today (Linux and Windows no longer need any
  setup); calling it stays harmless.

Agent skill:
[tekartik-app-platform-setup](skills/tekartik-app-platform-setup/SKILL.md).
