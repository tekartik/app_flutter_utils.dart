---
name: tekartik-app-flutter-widget-mini-ui
description: >-
  Use when a Flutter app needs quick dialogs or a throwaway debug/dev menu
  screen with tekartik_app_flutter_widget's mini_ui: the
  package:tekartik_app_flutter_widget/mini_ui.dart import, muiConfirm,
  muiGetString, muiSelectString, muiSnack / muiSnackSync, and the declarative
  menu API muiMenu, muiItem, MuiItem, showMuiMenu, muiScreenWidget,
  muiBodyWidget, MuiScreenWidget, MuiBodyWidget, MuiFutureOrVoidCallback and
  the muiBuildContext global.
---

# Mini UI: dialogs and dev menus (tekartik_app_flutter_widget)

`mini_ui.dart` bundles the four dialogs every app ends up rewriting (confirm,
input text, pick from a list, snack) and a tiny declarative menu DSL used to
build developer/test screens in a few lines.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_widget:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_widget
      version: '>=0.2.1'
  ```
* One import for the whole API:
  ```dart
  import 'package:tekartik_app_flutter_widget/mini_ui.dart';
  ```
  Never import anything under `lib/src/`.
* Dialogs (all need a `Navigator`, i.e. a `MaterialApp`/`Scaffold` above the
  context, and all are `await`ed):
  * `Future<bool> muiConfirm(context, {String message = 'Confirm operation'})`
    - Yes/No, returns `false` when dismissed (never null).
  * `Future<String?> muiGetString(context, {String? value, String? title,
    FormFieldValidator<String>? validator, String? hint})` - a one field form,
    `null` on cancel or when the validator rejects.
  * `Future<int?> muiSelectString(context, {required List<String> list,
    String? title, double? width})` - returns the **index** picked in the
    list, `null` on cancel.
  * `Future<void> muiSnack(context, message)` / `void muiSnackSync(context,
    message)` - hide the current snack bar then show a new one; they need a
    `ScaffoldMessenger` and also `print` the message.
* After an `await`, check `context.mounted` before using the same
  `BuildContext` again (`muiSnackSync` does it internally, the dialogs do
  not).
* Menu DSL, for debug/dev screens only:
  * `MuiScreenWidget(name: 'main', items: [MuiItem('label', callback), ...])`
    is a ready `Scaffold` with an `AppBar` and one `ListTile` per item; the
    callback is a `MuiFutureOrVoidCallback` (sync or async).
  * The declarative form avoids building the list by hand:
    `muiScreenWidget('name', () { muiItem('label', () {...}); })` returns the
    same widget, `muiBodyWidget(() { ... })` returns just the `ListView`
    (`MuiBodyWidget`) to embed in your own `Scaffold`, and `muiMenu('name',
    () { ... })` declares a sub menu.
  * `muiItem(...)` and `muiMenu(...)` only work **inside** a
    `muiScreenWidget` / `muiBodyWidget` / `muiMenu` body (they assert
    otherwise). A nested `muiMenu` becomes an item that pushes a new screen.
  * `showMuiMenu<T>(context, 'name', () { ... })` pushes a menu screen as a
    `MaterialPageRoute` and returns what the item popped, cast to `T?`
    (`null` when the type does not match).
  * Inside an item callback, `muiBuildContext` is the `BuildContext` of the
    tapped tile: use it for `Navigator.of(...)`, `muiSnack(...)` or a nested
    `showMuiMenu(...)`. It is a global set on tap, so it is only valid during
    the callback, never in `build()` nor after the screen is gone.
  * `muiItem(name, body, solo: true)` auto runs that item when the screen
    opens - it is annotated `@doNotSubmit`, so it is a local debugging
    shortcut, never committed.
* This is deliberately unstyled, ad hoc UI: use it for dev menus, manual test
  screens and quick prompts, not for the production UX of a feature.

## Examples

### The four dialogs

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';

class ItemActions extends StatelessWidget {
  final List<String> items;

  const ItemActions({super.key, required this.items});

  Future<void> _rename(BuildContext context) async {
    var index = await muiSelectString(
      context,
      title: 'Rename which item?',
      list: items,
    );
    if (index == null || !context.mounted) {
      return;
    }
    var name = await muiGetString(
      context,
      title: 'New name',
      value: items[index],
      hint: 'name',
      validator: (value) =>
          (value?.trim().isEmpty ?? true) ? 'Required' : null,
    );
    if (name == null || !context.mounted) {
      return;
    }
    items[index] = name;
    muiSnackSync(context, 'renamed to $name');
  }

  Future<void> _deleteAll(BuildContext context) async {
    if (await muiConfirm(context, message: 'Delete all items?')) {
      items.clear();
      if (context.mounted) {
        await muiSnack(context, 'deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => _rename(context),
          child: const Text('Rename'),
        ),
        TextButton(
          onPressed: () => _deleteAll(context),
          child: const Text('Delete all'),
        ),
      ],
    );
  }
}
```

### A dev menu screen with sub menus

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';

void main() {
  runApp(
    MaterialApp(
      home: muiScreenWidget('dev', () {
        muiItem('Snack', () {
          muiSnackSync(muiBuildContext, 'tap');
        });

        /// A nested menu becomes an item pushing a new screen.
        muiMenu('Database', () {
          muiItem('Info', () async {
            await muiSnack(muiBuildContext, 'db info');
          });
          muiItem('Clear', () async {
            var context = muiBuildContext;
            if (await muiConfirm(context, message: 'Clear the database?')) {
              if (context.mounted) {
                muiSnackSync(context, 'cleared');
              }
            }
          });
        });

        muiItem('Pick a value', () async {
          var context = muiBuildContext;
          var result = await showMuiMenu<String>(context, 'values', () {
            muiItem('one', () => Navigator.of(muiBuildContext).pop('one'));
            muiItem('two', () => Navigator.of(muiBuildContext).pop('two'));
          });
          if (context.mounted) {
            muiSnackSync(context, 'result $result');
          }
        });
      }),
    ),
  );
}
```

### Embedding the menu list in your own screen

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';

class DebugTab extends StatelessWidget {
  const DebugTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: Column(
        children: [
          const Text('Actions'),

          /// MuiBodyWidget: the list only, no Scaffold/AppBar.
          Expanded(
            child: muiBodyWidget(() {
              muiItem('Ping', () => muiSnackSync(muiBuildContext, 'pong'));
              muiItem('Crash', () => throw StateError('boom'));
            }),
          ),
        ],
      ),
    );
  }
}

/// The imperative form, when the items come from data.
MuiScreenWidget buildFromData(List<String> names) {
  return MuiScreenWidget(
    name: 'items',
    items: [
      for (var name in names)
        MuiItem(name, () async {
          await muiSnack(muiBuildContext, name);
        }),
    ],
  );
}
```
