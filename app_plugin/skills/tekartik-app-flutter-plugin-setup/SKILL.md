---
name: tekartik-app-flutter-plugin-setup
description: >-
  Use when a Flutter app must detect that the Android monkey tester
  (adb shell monkey / ActivityManager.isUserAMonkey) is driving it, with
  tekartik_app_flutter_plugin: the isMonkeyRunning future getter of
  package:tekartik_app_flutter_plugin/monkey.dart, its
  'tekartik_app_flutter_plugin' MethodChannel ('isMonkeyRunning',
  'getPlatformVersion'), the git dependency block, and mocking the channel
  with setMockMethodCallHandler in flutter_test.
---

# Monkey detection plugin (tekartik_app_flutter_plugin)

`tekartik_app_flutter_plugin` is a one-feature Flutter plugin: it tells the
Dart side whether the Android monkey tester is currently driving the app, so
destructive or paid actions can be skipped during a monkey run.

## Guidelines

* The package is not on pub.dev, depend on it from git:

  ```yaml
  dependencies:
    tekartik_app_flutter_plugin:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_plugin
      version: '>=0.1.0'
  ```

  It is a plugin package (native Android code), so a pure `dart test` /
  `dart run` consumer cannot use it: it needs a Flutter app build.
* The whole public API is one library,
  `package:tekartik_app_flutter_plugin/monkey.dart`, exposing a single
  `Future<bool> get isMonkeyRunning`. Everything else
  (`TekartikAppFlutterPlugin`, `platformVersion`, `callIsMonkeyRunning`) lives
  in `lib/src/` and is not part of the public API; do not import `src/`
  outside this package's own tests.
* `isMonkeyRunning` is a *getter returning a Future*: `await isMonkeyRunning`,
  never `isMonkeyRunning()`. Each read is a platform channel round trip;
  cache the value once at startup if it is checked often.
* It is Android only. On iOS, desktop and web it resolves to `false` without
  touching the channel (`Platform.isAndroid` guard), and any channel error is
  swallowed and reported as `false` (logged in debug). So a `true` result is
  trustworthy, a `false` result just means "not a known monkey run".
* Android side: the plugin answers the `isMonkeyRunning` method of the
  `tekartik_app_flutter_plugin` `MethodChannel` with
  `ActivityManager.isUserAMonkey()`, true while a
  `adb shell monkey -p <package> ...` run is driving the app.
* Because the check uses `dart:io` `Platform`, importing `monkey.dart` in
  code compiled for the web fails to build; keep it behind a platform
  specific file or an `if (!kIsWeb)` split in a web-targeting app.
* Typical use: wrap a purchase, a share sheet, a logout, a "delete all" or an
  analytics call in `if (!await isMonkeyRunning) { ... }`, and optionally
  show a monkey banner in debug.
* Testing: the plugin channel is not available in `flutter_test`, mock it
  with `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
  .setMockMethodCallHandler(channel, handler)` after
  `TestWidgetsFlutterBinding.ensureInitialized()`, and remember that
  `isMonkeyRunning` still returns `false` in a VM test since the host is not
  Android; test your own wrapper, not the getter itself.

## Examples

### Skip a destructive action while the monkey runs

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_plugin/monkey.dart';

class DangerZone extends StatelessWidget {
  const DangerZone({super.key});

  Future<void> _deleteAll(BuildContext context) async {
    // A getter returning a Future: await it, do not call it.
    if (await isMonkeyRunning) {
      // Monkey testing: never wipe the data.
      return;
    }
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => const AlertDialog(title: Text('Deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _deleteAll(context),
      child: const Text('Delete all'),
    );
  }
}
```

### Read it once at startup and keep it

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_plugin/monkey.dart';

/// True while `adb shell monkey` drives the app, false everywhere else.
late final bool monkeyRunning;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // One platform channel call instead of one per check.
  monkeyRunning = await isMonkeyRunning;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(monkeyRunning ? 'monkey mode' : 'normal mode'),
        ),
      ),
    );
  }
}
```

### Test with a mocked channel

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_plugin/monkey.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('tekartik_app_flutter_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isMonkeyRunning') {
            return true;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('always false off Android', () async {
    // The dart:io guard short circuits the channel on the test host.
    expect(await isMonkeyRunning, isFalse);
  });
}
```
