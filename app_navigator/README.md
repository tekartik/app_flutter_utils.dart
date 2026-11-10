# tekartik_app_navigator_flutter

A Navigator 2.0 router for `MaterialApp.router` built on typed, firestore
like content paths (`/school/1/student/2`): a `ContentPath` class describes a
route, a `ContentPageDef` binds it to a screen, `ContentNavigator` provides
the router delegate and the route information parser (browser urls, deep
links), plus `onResume` / `onPause` for screens.

Status: experimental, the API may still change (several Tekartik apps use
it); for a new app [go_router](https://pub.dev/packages/go_router) is the
usual choice.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_navigator_flutter:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_navigator
```

```dart
import 'package:material_ui/material_ui.dart'; // or flutter/material.dart
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

/// `/note/<id>`
class NotePath extends ContentPathBase {
  final note = ContentPathField('note');

  @override
  List<ContentPathField> get fields => [note];
}

final appDef = ContentNavigatorDef(
  defs: [
    // The root first: it is the initial page.
    ContentPageDef(
      path: rootContentPath,
      screenBuilder: (_) => Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => ContentNavigator.pushPath<void>(
              context,
              NotePath()..note.value = '1',
            ),
            child: const Text('Open note 1'),
          ),
        ),
      ),
    ),
    ContentPageDef(
      path: NotePath(), // wildcard value: matches any note
      screenBuilder: (rs) {
        var path = NotePath()..fromPath(rs.path);
        return Scaffold(
          appBar: AppBar(title: Text('Note ${path.note.value}')),
        );
      },
    ),
  ],
);

void main() {
  runApp(
    ContentNavigator(
      def: appDef,
      child: Builder(
        builder: (context) => MaterialApp.router(
          routerConfig: ContentNavigator.of(context).routerConfig,
        ),
      ),
    ),
  );
}
```

Complete app in [example/main.dart](example/main.dart).

## Platforms

Every Flutter platform. On the web the browser url follows the top page
(`/note/1`), a reload or a link opens it again.

## What to use

- Paths: a `ContentPathBase` subclass with its `fields`, a
  `ContentPathField(name, [value])` (`name/value`, a null or `*` value is a
  wildcard) or a `ContentPathPart(name)` (a bare segment); `rootContentPath`
  is `/`.
- Navigation, static on `ContentNavigator`: `pushPath`, `pushReplacementPath`,
  `popToRoot`, `popUntilPathOrPush`, `transientPop`; the push future
  completes with the pop result.
- `route_aware.dart`: `routeAwareObserver` (in `ContentNavigator.observers`)
  and `RouteAwareStateBase` with `onResume` / `onPause`.

## Common pitfalls

- Put the `rootContentPath` def first: the first def is the initial page.
- A url matching no def opens the home page (the root def, else the first
  one).
- Values can hold any character in the url (percent-encoded and decoded
  back, fixed 2026-11-10: a space, an accent, `%`, `?` or `#` changed the id
  on reload), but not `/`: the page name keeps the raw value and a `/` there
  reads back as more fields.
- A field value is set once (it asserts on a change): create a new path
  instance instead of changing a shared one.

Agent skill:
[tekartik-app-navigator-flutter-content-navigator](skills/tekartik-app-navigator-flutter-content-navigator/SKILL.md).
