---
name: tekartik-app-dev-menu-flutter-setup
description: >-
  Use when writing a Flutter dev/test menu app (tappable items with a console
  pane, like the tekartik *_test_app examples) or sharing one menu
  declaration between a Flutter app and a Dart CLI, with
  tekartik_app_dev_menu_flutter: mainMenuFlutter, mainMenuUniversal, mainMenu,
  initMainMenuFlutter/initTestMenuFlutter, menu, item, write, writeln, prompt,
  navigator, buildContext, keyValuesMenu, KeyValue, kvFromVar, the
  dev_menu_flutter.dart versus dev_menu.dart imports, showConsole/noConsole.
---

# Flutter dev menu (tekartik_app_dev_menu_flutter)

A dev menu is a tree of `menu('name', () { item('label', () async {...}); })`
declarations rendered by `tekartik_test_menu_flutter` as a list of tappable
items with an optional console pane (`write` output, `prompt` dialogs). This
package adds the Flutter entry points and re-exports the universal
`tekartik_app_dev_menu` API so one declaration also runs as a console or
browser menu.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_dev_menu_flutter:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_dev_menu
  ```
* Two imports, same declaration API:
  * `package:tekartik_app_dev_menu_flutter/dev_menu_flutter.dart`: Flutter
    only. Adds `mainMenuFlutter(body, {showConsole})`,
    `mainMenuUniversal(arguments, body, {noConsole})` (alias `mainMenu`),
    `initMainMenuFlutter` (alias of
    `initTestMenuFlutter({builder, showConsole})`), `navigator` and
    `buildContext`.
  * `package:tekartik_app_dev_menu_flutter/dev_menu.dart`: universal. Under
    Flutter (`dart:ui` available) it is the Flutter implementation above;
    compiled without Flutter (a `dart run` script, a plain web build) it
    delegates `mainMenuUniversal`/`mainMenu` to `tekartik_app_dev_menu`
    (console on io, browser menu on the web). Use it in code that both a
    Flutter app and a CLI import. `navigator`/`buildContext` are only
    available from `dev_menu_flutter.dart`.
* Both re-export `package:tekartik_app_dev_menu/dev_menu.dart` (minus its own
  `mainMenu`/`mainMenuUniversal`): the `dev_build` menu primitives
  `menu(name, body, {cmd, group, solo})`, `item(name, body, {cmd, solo})`,
  `write(message)`, `writeln(message)`, `prompt([message])` (returns
  `Future<String>`), `command(body)`, `enter`/`leave`, `enterItem`/`leaveItem`,
  `showMenu`, `popMenu`, `menuRun`, `solo_item`/`solo_menu` (marked
  `@doNotSubmit`, for local focus only), plus the key/value helpers
  `KeyValue`, `'key'.kvFromVar(defaultValue:)`, `kv.get()`, `kv.set(value)`,
  `kv.delete()` and `keyValuesMenu(name, kvs)`.
* Structure: keep declarations in `lib/` functions (`void defineMenu() {
  menu(...); }`) and call them from `main`. `menu` bodies must be synchronous
  and only declare; `item` bodies may be `async` and return a `Future`.
  Uncaught exceptions of an item are reported in the console, they do not
  crash the app.
* `mainMenuFlutter(body, showConsole: true)` runs the menu `MaterialApp`,
  calls `body()` once inside the tree (guarded against the double call of a
  hot restart) and shows the console pane: `write` lines (the last 200 are
  kept, also printed to stdout with an `[o]` prefix) and a text dialog for
  `prompt`. `showConsole: false` hides the pane.
* `mainMenuUniversal(args, body, {noConsole})` is the signature to use in a
  `main(List<String> args)` shared with a CLI; on Flutter `noConsole` false
  (default) means console shown, on the CLI side `args` select items
  directly.
* Navigation from an item: `await navigator.push<void>(MaterialPageRoute(
  builder: (_) => page))` or `Navigator.of(buildContext!)`. `buildContext` is
  the root menu page context, `null` before the first frame; `navigator`
  throws when it is `null`. Popping the page returns to the menu; code after
  the `await` runs then.
* `initMainMenuFlutter(builder: (child) => Wrapper(child: child), showConsole:)`
  is the lower level: it `runApp`s the menu app (wrapped by `builder`) and
  installs the presenter; `mainMenuFlutter` is implemented on it and declares
  the menu from inside `builder`. Reach for it only to add providers or a
  theme around the menu app.
* Key/values (`keyValuesMenu`) persist through the `tekartik_test_menu_io`
  var storage (environment-like, file backed): a desktop/CLI feature; on a
  phone treat `KeyValue` as in-memory settings.
* This package has no tests; the test apps of `app_flutter_utils.dart`
  (`example/*_test_app_lib`) are the reference usage.

## Examples

### Flutter dev menu with console, prompt and navigation

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_dev_menu_flutter/dev_menu_flutter.dart';

Future<void> _push(Widget page) async {
  await navigator.push<void>(MaterialPageRoute(builder: (_) => page));
}

void defineMenu() {
  menu('demo', () {
    item('write', () {
      write('Hello at ${DateTime.now()}');
    });
    item('prompt', () async {
      var name = await prompt('Your name');
      write('Hi $name');
    });
    item('open page', () async {
      await _push(
        Scaffold(
          appBar: AppBar(title: const Text('Page')),
          body: const Center(child: Text('Back returns to the menu')),
        ),
      );
      write('page closed');
    });
    menu('sub', () {
      item('throws', () => throw StateError('boom'));
    });
  });
}

void main() {
  mainMenuFlutter(() {
    defineMenu();
  }, showConsole: true);
}
```

### One declaration for the Flutter app and the CLI

```dart
// lib/api_menu.dart: imported by the Flutter main and by bin/api_menu.dart.
import 'package:tekartik_app_dev_menu_flutter/dev_menu.dart';

void defineApiMenu() {
  menu('api', () {
    item('ping', () async {
      write('pong');
    });
    item('echo', () async {
      writeln(await prompt('text'));
    });
  });
}

Future<void> main(List<String> args) async {
  // Flutter menu when built with Flutter, console/browser menu otherwise.
  mainMenuUniversal(args, defineApiMenu);
}
```

### Persisted key/values edited from the menu

```dart
import 'package:tekartik_app_dev_menu_flutter/dev_menu.dart';

var serverUrl = 'server_url'.kvFromVar(defaultValue: 'http://localhost:8080');

void main(List<String> args) {
  mainMenu(args, () {
    keyValuesMenu('settings', [serverUrl]);
    menu('client', () {
      item('show url', () => write(serverUrl.get()));
      item('set url', () async => serverUrl.set(await prompt('url')));
      item('reset url', () async => serverUrl.delete());
    });
  });
}
```

### Menu app wrapped in a provider/theme

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_dev_menu_flutter/dev_menu_flutter.dart';

void main() {
  var declared = false;
  initMainMenuFlutter(
    showConsole: true,
    builder: (child) => Theme(
      data: ThemeData.dark(),
      child: Builder(
        builder: (_) {
          if (!declared) {
            declared = true;
            menu('dark', () {
              item('hello', () => write('hello'));
            });
          }
          return child;
        },
      ),
    ),
  );
}
```
