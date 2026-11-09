# tekartik_app_flutter_plugin

A one-feature Flutter plugin: tells whether the Android
[monkey](https://developer.android.com/studio/test/other-testing-tools/monkey)
tester is driving the app (`ActivityManager.isUserAMonkey()`), so that a
purchase, a share sheet or a "delete all" can be skipped during a monkey run.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_plugin:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_plugin
```

Check it before a destructive or paid action:

```dart
import 'package:tekartik_app_flutter_plugin/monkey.dart';

Future<void> deleteAll() async {
  // A getter returning a Future: await it, do not call it.
  if (await isMonkeyRunning) {
    return; // Never wipe the data during a monkey run.
  }
  // ...delete everything
}
```

Run the monkey on the app:

```bash
adb shell monkey -p <applicationId> -v --pct-touch 98 --pct-majornav 1 --pct-motion 1 5000
```

## Platforms

| Platform | `isMonkeyRunning` |
|---|---|
| Android | `ActivityManager.isUserAMonkey()` through the plugin channel |
| iOS, macOS, Linux, Windows, web | always `false`, the channel is not called |

A channel error (plugin not registered...) also gives `false`, so `true` can
be trusted, `false` only means "not a known monkey run".

## Notes

- `monkey.dart` is the whole public API; do not import `lib/src/`.
- Each call is a platform channel round trip on Android: read it once at
  startup when it is checked often.
- In `flutter test` (not Android) it is always `false`: test your own
  wrapper, see the package skill for a mocked channel.
