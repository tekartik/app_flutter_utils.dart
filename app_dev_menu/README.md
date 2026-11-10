# tekartik_app_dev_menu_flutter

A developer / manual test menu as a Flutter app: tappable menus and items,
a console pane for their output (`write`) and dialogs for `prompt`. The same
declaration also runs as a console menu (`dart run`) or a browser page
through [tekartik_app_dev_menu](https://github.com/tekartik/app_common_utils.dart/tree/master/app_dev_menu),
whose API (`menu`, `item`, `write`, `prompt`, key values) it re-exports.

## Getting started

Git package (not on pub.dev):

```yaml
dependencies:
  tekartik_app_dev_menu_flutter:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_dev_menu
```

`lib/main.dart` of a Flutter app (any platform: Android, iOS, web,
desktop):

```dart
import 'package:tekartik_app_dev_menu_flutter/dev_menu_flutter.dart';

void main() {
  mainMenuFlutter(() {
    menu('demo', () {
      item('write', () => write('Hello at ${DateTime.now()}'));
      item('prompt', () async {
        var name = await prompt('Your name');
        write('Hi $name');
      });
    });
    item('throws', () => throw StateError('shown in the console'));
  });
}
```

`flutter run`: tap `demo`, then `write`; the output shows in the console
pane (and on stdout with an `[o]` prefix). The full example:
[example/main.dart](example/main.dart).

## Two imports

- `package:tekartik_app_dev_menu_flutter/dev_menu_flutter.dart`: Flutter
  only. `mainMenuFlutter(body, {showConsole})`, `mainMenu(arguments, body,
  {noConsole})`, `initMainMenuFlutter({builder, showConsole})` (to wrap the
  menu app, e.g. in providers), `navigator` and `buildContext` (to push a
  page from an item).
- `package:tekartik_app_dev_menu_flutter/dev_menu.dart`: for a declaration
  shared with a CLI. In a Flutter build `mainMenu` is the Flutter menu;
  compiled without Flutter (`dart run bin/menu.dart`, a plain Dart web
  build) it is the console or browser menu of tekartik_app_dev_menu, its
  `arguments` typed first (`dart run bin/menu.dart 0 1 . .`). No
  `navigator` there.

## Pitfalls

- A `menu` body only declares (synchronous); an `item` body may be async.
  An item that throws is reported in the console, the app keeps running.
- `navigator` and `buildContext` are the root menu page: null until the
  menu is shown (`navigator` throws then). Pushing a page from an item needs
  the material widgets (`package:material_ui/material_ui.dart`, the
  `material_ui` package, rather than `package:flutter/material.dart`).
- The menu app has its own `MaterialApp` and light/dark themes (switched in
  its settings): a `Theme` around it from `initMainMenuFlutter(builder:)`
  has no effect.
- Key values (`'KEY'.kvFromVar()`, `keyValuesMenu`) are saved in
  `.local/ds_env.yaml` under the working directory on io (desktop, CLI)
  and in `localStorage` on the web; do not rely on them in a phone app.
- Never write a secret in the source: read it through a key value.

Agent skill: [skills/tekartik-app-dev-menu-flutter-setup/SKILL.md](skills/tekartik-app-dev-menu-flutter-setup/SKILL.md).
Real menus: the `example/*_test_app_lib` packages of this repository.
