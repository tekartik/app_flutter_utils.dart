# tekartik_app_prefs

App preferences (settings) for a Flutter app on every platform, through the
[tekartik_prefs](https://github.com/tekartik/prefs.dart/tree/main/prefs) API
(named prefs, versions and migrations, sync or async flavors), which it
re-exports: shared_preferences on Android, iOS and macOS, the browser local
storage on the web, a sembast file on Linux and Windows.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_prefs:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_prefs
```

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_prefs/app_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Once: packageName is the prefs folder on Linux and Windows.
  var factory = getPrefsFactory(packageName: 'com.example.myapp');
  var prefs = await factory.openPreferences('settings');
  var launches = (prefs.getInt('launches') ?? 0) + 1;
  prefs.setInt('launches', launches); // saved in the background
  runApp(
    Center(
      child: Text('Launch #$launches', textDirection: TextDirection.ltr),
    ),
  );
}
```

Complete app in [example/main.dart](example/main.dart).

## Platforms

| Platform | `getPrefsFactory(packageName:)` and its async twins | `prefsFactory` getters |
|---|---|---|
| Android, iOS, macOS | shared_preferences | shared_preferences |
| Linux, Windows | sembast file `<userAppDataPath>/<packageName>/prefs/<name>` | shared_preferences |
| Web | local storage, keys `<name>/<key>` | local storage |
| Unit tests | `newPrefsFactoryMemory()` / `prefsFactoryMemory` | |

## What to use

- `app_prefs.dart`: `getPrefsFactory`, sync `Prefs` (loaded in memory when
  opened, synchronous reads, background saves). The usual choice.
- `app_prefs_async.dart`: `getPrefsAsyncFactory`, `PrefsAsync` (every read
  and write is a `Future`).
- `app_prefs_async_with_cache.dart`: `getPrefsAsyncWithCacheFactory`
  (synchronous reads from a cache, awaited writes).
- `app_prefs_light.dart`: `prefsFlutter`, one global shared_preferences key
  value store (no names, no versions).

## Common pitfalls

- Use `getPrefsFactory(packageName:)` everywhere, not the `prefsFactory`
  getter: on Linux and Windows they are two storages (a sembast file and
  shared_preferences), code mixing them reads empty prefs.
- Without `packageName`, the Linux and Windows prefs go to
  `<userAppDataPath>/com.tekartik.app_prefs`, shared by every app.
- Writes of the sync `Prefs` are saved in the background: `await
  prefs.save()` when it must be on disk now.
- On the web and with shared_preferences a prefs `a` owns every key starting
  with `a/`: it sees and clears the keys of a prefs `a/b` (a
  `factory.sandbox(path: 'a')`). Do not name a prefs like the sandbox of
  another one.

Agent skill:
[tekartik-app-prefs-setup](skills/tekartik-app-prefs-setup/SKILL.md).
