---
name: tekartik-app-prefs-setup
description: >-
  Use when storing app preferences/settings in a Flutter app with
  tekartik_app_prefs: getPrefsFactory(packageName:) / prefsFactory (sync Prefs,
  openPreferences, deletePreferences, getInt/setInt/getString/setString/getMap/
  setList, save, close), getPrefsAsyncFactory / prefsAsyncFactory (PrefsAsync),
  getPrefsAsyncWithCacheFactory / prefsAsyncWithCacheFactory
  (PrefsAsyncWithCache), the prefsFlutter PrefsLight of app_prefs_light.dart,
  the memory factories (prefsFactoryMemory, newPrefsAsyncFactoryMemory) and
  sandbox(path:) for tests, and the app_prefs.dart / app_prefs_async.dart /
  app_prefs_async_with_cache.dart / app_prefs_light.dart imports.
---

# App preferences (tekartik_app_prefs)

`tekartik_app_prefs` picks the right `tekartik_prefs` implementation for the
platform the Flutter app runs on: shared_preferences on mobile, indexed db in
the browser, and a sembast file under the user data directory on Linux and
Windows. Application code only sees the `tekartik_prefs` API, which the
package re-exports.

## Guidelines

* The package is not on pub.dev, depend on it from git:

  ```yaml
  dependencies:
    tekartik_app_prefs:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_prefs
      version: '>=0.1.0'
  ```

* Pick one of the four libraries, each re-exports the matching
  `tekartik_prefs` API so a single import is enough:
  * `package:tekartik_app_prefs/app_prefs.dart`: `prefsFactory`,
    `getPrefsFactory({packageName})`, `Prefs` (synchronous reads and writes,
    the whole prefs is loaded in memory when opened). The usual choice.
  * `package:tekartik_app_prefs/app_prefs_async.dart`: `prefsAsyncFactory`,
    `getPrefsAsyncFactory({packageName})`, `PrefsAsync` (every read and write
    is a `Future`, nothing cached).
  * `package:tekartik_app_prefs/app_prefs_async_with_cache.dart`:
    `prefsAsyncWithCacheFactory`, `getPrefsAsyncWithCacheFactory({packageName})`,
    `PrefsAsyncWithCache` (synchronous reads from a cache, asynchronous
    writes).
  * `package:tekartik_app_prefs/app_prefs_light.dart`: `prefsFlutter`, a
    single global `PrefsLight` key/value store backed directly by
    `shared_preferences`, with no named prefs and no version. For a handful
    of settings.
* Always prefer `getPrefsFactory(packageName: 'com.example.my_app')` over the
  bare `prefsFactory` getter: on Linux and Windows the package name is the
  folder under the user data path where the sembast database is written
  (without it everything lands in a shared `com.tekartik.app_prefs` folder).
  It is ignored on mobile and web. Call it once and keep the factory.
* `factory.openPreferences(name, {version, onVersionChanged})` returns a
  `Future<Prefs>`; `name` is a store name, not a file path. Keep the `Prefs`
  open for the app lifetime, `close()` it only when done.
  `factory.deletePreferences(name)` erases it. `factory.hasStorage` is false
  for the memory implementation.
* Sync `Prefs` API: `getBool`/`getInt`/`getDouble`/`getString` return null
  when absent, `getMap`/`getList` (extension) decode a json string;
  `setBool`/`setInt`/`setDouble`/`setString`/`setMap`/`setList` take a
  nullable value where null means remove, plus `remove(key)`, `clear()`,
  `containsKey(key)`, `keys`. Writes are saved in the background: `await
  prefs.save()` before exiting if a write must be flushed.
* `PrefsAsync` is the shared_preferences-like async API
  (`await prefs.getInt('x')`, `await prefs.setInt('x', 1)`, non nullable
  values, `remove`, `clear`, `getKeys()`, `getAll()`,
  `getStringList`/`setStringList`) with `setIntOrNull`, `setStringOrNull`,
  `setMap`, `setList`, `getMap`, `getList` extensions.
  `factory.init(options: PrefsAsyncFactoryOptions(strictType: true))` turns
  off the implicit type conversions (and the map/list extensions).
* Migrations: pass `version:` and `onVersionChanged: (prefs, oldVersion,
  newVersion) { ... }` to `openPreferences`; the callback gets the prefs
  object to fix up.
* Tests and previews: use `prefsFactoryMemory` / `newPrefsFactoryMemory()`
  (or `prefsAsyncFactoryMemory`, `newPrefsAsyncFactoryMemory()`,
  `prefsAsyncWithCacheFactoryMemory`), all exported by the same imports. A
  fresh `newPrefsFactoryMemory()` per test keeps tests isolated.
* `factory.sandbox(path: 'test')` (extension on `PrefsFactory` and
  `PrefsAsyncFactory`) returns a factory whose prefs all live under `path`:
  handy to isolate a test or a feature without touching the real prefs.
* A widget test needs `TestWidgetsFlutterBinding.ensureInitialized()` and, if
  it really goes through the flutter implementation, the
  `PrefsFactoryFlutterMock()` of `package:tekartik_prefs_flutter/prefs_mock.dart`
  (add `tekartik_prefs_flutter` as a dev dependency); the memory factory is
  simpler.
* Prefs are not a database: no queries, no transactions, everything is loaded
  in memory in the sync flavor. Use `tekartik_app_sembast` /
  `tekartik_app_idb` for real data.

## Examples

### Open the app prefs once and use them

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_prefs/app_prefs.dart';

/// Desktop needs the package name to find its data folder.
final appPrefsFactory = getPrefsFactory(packageName: 'com.example.my_app');

late Prefs appPrefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  platformInit();
  appPrefs = await appPrefsFactory.openPreferences('settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var dark = appPrefs.getBool('dark') ?? false;
    return MaterialApp(
      theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              appPrefs.setBool('dark', !dark);
              // Writes are saved in the background, force it if needed.
              await appPrefs.save();
            },
            child: const Text('Toggle theme'),
          ),
        ),
      ),
    );
  }
}
```

### Typed settings holder with a version migration

```dart
import 'package:tekartik_app_prefs/app_prefs.dart';

class AppSettings {
  final Prefs prefs;

  AppSettings(this.prefs);

  static Future<AppSettings> open({PrefsFactory? factory}) async {
    var prefsFactory =
        factory ?? getPrefsFactory(packageName: 'com.example.my_app');
    var prefs = await prefsFactory.openPreferences(
      'settings',
      version: 2,
      onVersionChanged: (prefs, oldVersion, newVersion) {
        if (oldVersion < 2) {
          // Renamed in version 2.
          prefs.setString('userName', prefs.getString('name'));
          prefs.remove('name');
        }
      },
    );
    return AppSettings(prefs);
  }

  String? get userName => prefs.getString('userName');

  set userName(String? value) => prefs.setString('userName', value);

  int get launchCount => prefs.getInt('launchCount') ?? 0;

  Map<String, Object?>? get lastQuery => prefs.getMap('lastQuery');

  void trackLaunch() => prefs.setInt('launchCount', launchCount + 1);

  void setLastQuery(Map<String, Object?> query) =>
      prefs.setMap('lastQuery', query);

  Future<void> close() => prefs.close();
}
```

### Async (or async with cache) flavor

```dart
import 'package:tekartik_app_prefs/app_prefs_async.dart';
import 'package:tekartik_app_prefs/app_prefs_async_with_cache.dart';

Future<void> asyncPrefs() async {
  var factory = getPrefsAsyncFactory(packageName: 'com.example.my_app');
  var prefs = await factory.openPreferences('settings');

  await prefs.setString('token', 'abc');
  await prefs.setIntOrNull('retry', null); // removes the key
  var token = await prefs.getString('token');
  var all = await prefs.getAll(); // every key and value
  assert(token != null && all.isNotEmpty);
  await prefs.close();
}

Future<void> asyncWithCachePrefs() async {
  var factory = getPrefsAsyncWithCacheFactory(
    packageName: 'com.example.my_app',
  );
  var prefs = await factory.openPreferences('settings');

  // Reads are synchronous (cached), writes are awaited.
  var count = prefs.getInt('count') ?? 0;
  await prefs.setInt('count', count + 1);
  await prefs.close();
}
```

### Light prefs (shared_preferences directly)

```dart
import 'package:tekartik_app_prefs/app_prefs_light.dart';

/// One global key/value store, no open/close, no named prefs.
Future<bool> toggleOnboardingDone() async {
  var done = await prefsFlutter.getBool('onboardingDone') ?? false;
  await prefsFlutter.setBool('onboardingDone', !done);
  return !done;
}

/// In a test, swap it for the in memory implementation.
PrefsLight newTestPrefsLight() => PrefsMemory();
```

### Tests: memory factory and sandbox

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_prefs/app_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('settings round trip', () async {
    // Never touches the device storage.
    var factory = newPrefsFactoryMemory();
    expect(factory.hasStorage, isFalse);

    var prefs = await factory.openPreferences('settings');
    expect(prefs.getInt('count'), isNull);
    prefs.setInt('count', 1);
    prefs.setMap('query', {'text': 'hello'});
    await prefs.save();
    expect(prefs.getInt('count'), 1);
    expect(prefs.getMap('query'), {'text': 'hello'});
    expect(prefs.keys, contains('count'));
    await prefs.close();
  });

  test('sandbox isolates a feature', () async {
    var factory = newPrefsFactoryMemory();
    var sandboxed = factory.sandbox(path: 'feature1');
    var prefs = await sandboxed.openPreferences('settings');
    prefs.setString('key', 'value');
    await prefs.close();

    // Same name, different tree.
    var other = await factory.openPreferences('settings');
    expect(other.getString('key'), isNull);
    await other.close();
  });
}
```
