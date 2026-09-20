---
name: tekartik-app-navigator-flutter-content-navigator
description: >-
  Use when routing a Flutter app with the experimental
  tekartik_app_navigator_flutter content navigator: ContentPath /
  ContentPathBase / ContentPathField / ContentPathPart typed paths
  (coll/id/coll/id), rootContentPath, ContentPageDef, ContentNavigatorDef,
  ContentNavigator (of, push, pushPath, pushReplacementPath, popToRoot,
  popUntilPathOrPush, transientPop, pushBuilder), ContentNavigatorBloc with
  routerDelegate / routeInformationParser / routerConfig for
  MaterialApp.router, ContentPathRouteSettings, ContentRouterDelegate,
  ContentRouteInformationParser, NoAnimationTransitionDelegate,
  NoAnimationMaterialPageRoute, and the routeAwareObserver / RouteAwareMixin /
  RouteAwareStateBase onResume-onPause support.
---

# Content navigator (tekartik_app_navigator_flutter)

`tekartik_app_navigator_flutter` is an experimental Navigator 2.0 router built
on typed, firestore-like content paths (`/school/1/student/2`): a
`ContentPath` subclass describes a route, a `ContentPageDef` binds it to a
screen builder, and `ContentNavigator` provides the `RouterDelegate` and
`RouteInformationParser` for `MaterialApp.router`.

Its README says **work in progress, do not use**: expect breaking changes and
prefer `go_router` for new apps. Use this skill when reading or maintaining an
app that already depends on it.

## Guidelines

* The package is not on pub.dev, depend on it from git:

  ```yaml
  dependencies:
    tekartik_app_navigator_flutter:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_navigator
      version: '>=0.4.5'
  ```

  It pulls `tekartik_app_flutter_bloc` (same repo, `path: app_bloc`):
  `ContentNavigator` is a `BlocProvider` of a `ContentNavigatorBloc`.
* Three public libraries:
  * `package:tekartik_app_navigator_flutter/content_navigator.dart`: paths,
    page definitions, the navigator, the router delegate and parser.
  * `package:tekartik_app_navigator_flutter/route_aware.dart`:
    `routeAwareObserver`, `RouteAwareMixin`, `RouteAwareStateBase`
    (`RouteAwareState` alias), `RouteAwareStatefulWidget`,
    `RouteAwareWithPath`, `RouteAwareWidgetState`.
  * `package:tekartik_app_navigator_flutter/page_route.dart`:
    `NoAnimationMaterialPageRoute`.
* Declaring a path: extend `ContentPathBase` and expose the ordered `fields`.
  A `ContentPathField(name, [value])` is a `name/value` pair (value `null` or
  `'*'` is a wildcard); a `ContentPathPart(name)` is a bare segment (value
  `''`). `rootContentPath` is `/` (`rootContentPathString`). Build an
  untyped path with `ContentPath.fromString('/school/1/student/2')`.
* A field value can only be set once: `field.value = x` asserts when the
  field already holds a different non null value. Create a new path instance
  instead of mutating a shared one. Copy the values of another path with
  `target.fromPath(source)` (matches by field name); read them back with
  `path.field('student')?.value` or `path.toStringMap()`.
* Path helpers: `toPathString()` (never `toString()`), `matchesPath(other)` /
  `matchesString('/school/1/student/2')` (wildcards match any value, but a
  `ContentPathPart` never matches a valued field), `startsWith(path)`,
  `isValid()` (every field has a real value, required to push).
* Definitions: `ContentPageDef(path: MyPath(), screenBuilder: (rs) => ...)`
  where `rs` is a `ContentPathRouteSettings` (`rs.path`, `rs.arguments`).
  Group them in `ContentNavigatorDef(defs: [...])`. **The first def is the
  root/initial page** (it is what is built when the stack is empty), so put
  the `rootContentPath` def first. `defs.findContentPageDef(path)`,
  `defs.override(def)` and `defs.overrideAll(defs)` (extensions on
  `List<ContentPageDef>`) let an app replace a shared definition; two defs
  with the same path are asserted against in debug.
* Wiring: wrap the app in `ContentNavigator(def: ..., child: ...)` (`child`
  is required in practice) and, inside, get the bloc with
  `ContentNavigator.of(context)` to feed `MaterialApp.router`, either with
  `routerDelegate:` + `routeInformationParser:` or with the single
  `routerConfig: cn.routerConfig`. `observers:` on `ContentNavigator` is the
  `NavigatorObserver` list of the inner `Navigator`.
* Navigation from a screen, all static on `ContentNavigator`:
  `pushPath<T>(context, path, {arguments, transitionDelegate})`,
  `pushReplacementPath<T>(context, path, {arguments, result})`,
  `push<T>(context, rs)` / `pushReplacement<T>(context, rs)` with an explicit
  `path.routeSettings(arguments)`, `popToRoot(context)`,
  `popUntilPathOrPush(context, path)`, `transientPopUntilPath(context, path)`,
  `transientPop(context, [result])`, and `pushBuilder<T>(context, builder:
  ..., noAnimation: true)` for a plain pageless route. The push future
  completes with the pop result.
* The same operations exist on the bloc (`ContentNavigator.of(context)`):
  `pushPath`, `push`, `currentPath`, `currentRoutePath`, `findPath`,
  `lastIndexWhere`, `transientPopUntil(index)`, `transientPopAll()`,
  `setNewRoutePath`. `TekartikNavigatorStateExt.popUntilPath(path)` extends
  `NavigatorState` for the imperative case.
* Pushing a path that has no matching def throws `StateError`; pushing an
  invalid (wildcard) path throws `ArgumentError` in debug. Parsing an unknown
  url in `ContentRouteInformationParser` throws `StateError` too, so declare
  every deep link as a def.
* Transitions: pass `transitionDelegate: const NoAnimationTransitionDelegate()`
  per push, or set `ContentNavigatorBloc.transitionDelegate` for the whole
  app. `NoAnimationMaterialPageRoute` does the same for imperative pushes.
* Resume/pause: add `routeAwareObserver` to `ContentNavigator.observers`,
  then make a screen state extend `RouteAwareStateBase<T>` (or mix
  `RouteAware, RouteAwareMixin<T>` in and call
  `routeAwareDidChangeDependencies()` / `routeAwareDispose()`) and override
  `onResume()` / `onPause()` (always call `super`). `resumed` tells the
  current state. A widget implementing `RouteAwareWithPath` (e.g. extending
  `RouteAwareStatefulWidget`) is not resumed when the pop that revealed it
  also popped its own path.
* Set `contentNavigatorDebug = true` for verbose routing logs.
  `contentNavigatorUseOnPopPage` switches back to the pre Flutter 3.24
  `onPopPage` behaviour, leave it `false`.
* Testing: the path logic is pure Dart (`package:test`), the navigator needs
  `testWidgets` and a `ContentNavigator` above a `MaterialApp.router`, see
  `test/path_test.dart` and `test/content_navigator_test.dart`.

## Examples

### Typed paths, defs and the router app

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

/// `/` the home page.
class HomePath extends ContentPathBase {
  @override
  List<ContentPathField> get fields => const <ContentPathField>[];
}

/// `/school/<id>/student/<id>`.
class StudentPath extends ContentPathBase {
  final school = ContentPathField('school');
  final student = ContentPathField('student');

  @override
  List<ContentPathField> get fields => [school, student];

  /// Definition path (wildcard values).
  StudentPath();

  /// Concrete path to push.
  StudentPath.value({required String schoolId, required String studentId}) {
    school.value = schoolId;
    student.value = studentId;
  }
}

final appDef = ContentNavigatorDef(
  defs: [
    // The first def is the initial page.
    ContentPageDef(
      path: rootContentPath,
      screenBuilder: (rs) => const HomeScreen(),
    ),
    ContentPageDef(
      path: StudentPath(),
      screenBuilder: (rs) {
        var path = StudentPath()..fromPath(rs.path);
        return StudentScreen(studentId: path.student.value!);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentNavigator(
      def: appDef,
      child: Builder(
        builder: (context) {
          var cn = ContentNavigator.of(context);
          return MaterialApp.router(
            title: 'My app',
            routerDelegate: cn.routerDelegate,
            routeInformationParser: cn.routeInformationParser,
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => ContentNavigator.pushPath<void>(
            context,
            StudentPath.value(schoolId: '1', studentId: '2'),
          ),
          child: const Text('Open student 2'),
        ),
      ),
    );
  }
}

class StudentScreen extends StatelessWidget {
  final String studentId;

  const StudentScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student $studentId')),
      body: Center(
        child: TextButton(
          onPressed: () => ContentNavigator.popToRoot(context),
          child: const Text('Home'),
        ),
      ),
    );
  }
}
```

### Pushing, awaiting a result, replacing and popping

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

class EditPath extends ContentPathBase {
  final edit = ContentPathField('edit');

  @override
  List<ContentPathField> get fields => [edit];

  EditPath([String? id]) {
    edit.value = id;
  }
}

Future<void> editThenReplace(BuildContext context, String id) async {
  // The future completes with the pop result of the pushed page.
  var saved = await ContentNavigator.pushPath<bool>(
    context,
    EditPath(id),
    arguments: {'from': 'list'},
    transitionDelegate: const NoAnimationTransitionDelegate(),
  );
  if (saved ?? false) {
    if (context.mounted) {
      // Pop the current page and push the next one in its place.
      await ContentNavigator.pushReplacementPath<void>(
        context,
        EditPath('$id-done'),
      );
    }
  }
}

void closeEditor(BuildContext context, bool saved) {
  // Regular Navigator pop, the pushPath future above gets the result.
  Navigator.of(context).pop(saved);
}

void backToList(BuildContext context) {
  // Pop until the path is on top, push it if it is not in the stack.
  ContentNavigator.popUntilPathOrPush(context, rootContentPath);
}
```

### Resume/pause aware screen

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:tekartik_app_navigator_flutter/route_aware.dart';

final homeDef = ContentPageDef(
  path: rootContentPath,
  screenBuilder: (rs) => const HomeScreen(),
);

class RouteAwareApp extends StatelessWidget {
  const RouteAwareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentNavigator(
      def: ContentNavigatorDef(defs: [homeDef]),
      // Required for onResume()/onPause() to be called.
      observers: [routeAwareObserver],
      child: Builder(
        builder: (context) =>
            MaterialApp.router(routerConfig: ContentNavigator.of(context).routerConfig),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends RouteAwareStateBase<HomeScreen> {
  @override
  void onResume() {
    super.onResume(); // sets `resumed`
    // Start listening / refresh.
  }

  @override
  void onPause() {
    super.onPause();
    // Stop listening.
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('resumed: $resumed')));
}
```

### Unit testing paths

```dart
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:test/test.dart';

class SchoolStudentPath extends ContentPathBase {
  final school = ContentPathField('school');
  final student = ContentPathField('student');

  @override
  List<ContentPathField> get fields => [school, student];
}

void main() {
  test('path matching', () {
    var def = SchoolStudentPath(); // wildcards
    expect(def.toPathString(), '/school/*/student/*');
    expect(def.isValid(), isFalse);
    expect(def.matchesString('/school/1/student/2'), isTrue);
    expect(def.matchesString('/school/1'), isFalse);

    var path = SchoolStudentPath()
      ..fromPath(ContentPath.fromString('/school/1/student/2'));
    expect(path.student.value, '2');
    expect(path.isValid(), isTrue);
    expect(path.toPathString(), '/school/1/student/2');
    expect(path.toStringMap(), {'school': '1', 'student': '2'});
    expect(path.startsWith(def), isTrue);
  });
}
```
