# tekartik_app_flutter_firebase

Firebase for a Flutter app through the Tekartik firebase abstraction: one
`firebase` getter typed as the `Firebase` interface of
[tekartik_firebase](https://github.com/tekartik/firebase.dart/tree/main/firebase),
backed by `firebase_core` (through
[tekartik_firebase_flutter](https://github.com/tekartik/firebase_flutter/tree/main/firebase_flutter)).
Shared code only sees `Firebase` / `FirebaseApp` and runs unchanged on the
in-memory implementation in unit tests.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_firebase:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_firebase
```

The FlutterFire setup is still yours: `flutterfire configure` (which writes
`firebase_options.dart`), or `google-services.json` /
`GoogleService-Info.plist` and the web configuration.

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Once, with the platform default options.
  var app = await firebase.initializeAppAsync();
  runApp(
    Center(
      child: Text(app.projectId, textDirection: TextDirection.ltr),
    ),
  );
}
```

With the generated options, wrap them (`wrapOptions` comes from
tekartik_firebase_flutter, a dependency of this package):

```dart
import 'package:tekartik_app_flutter_firebase/firebase.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_firebase_flutter/firebase_flutter.dart'
    show FirebaseFlutterExtension;

import 'firebase_options.dart'; // written by flutterfire configure

Future<FirebaseApp> initFirebase() => firebase.initializeAppAsync(
  options: firebase.wrapOptions(DefaultFirebaseOptions.currentPlatform),
);
```

Complete app in [example/main.dart](example/main.dart).

## Platforms

Android, iOS, macOS, web and Windows (the `firebase_core` platforms). Linux
has no `firebase_core` implementation: `initializeAppAsync` fails there.

## What to use

- `firebase` (`Firebase`): `initializeAppAsync({options, name})`, `app()`
  (the default app once initialized), `isLocal` (false).
- `FirebaseApp` (alias `App`): `name`, `options`, `projectId`, `delete()`.
  Pass it to the products of the sibling packages
  (`tekartik_app_flutter_firebase_firestore`, `..._auth`, `..._storage`).
- `app.nativeInstance` (`FirebaseAppFlutterExtension` of
  tekartik_firebase_flutter): the `firebase_core` app, for FlutterFire
  plugins outside the Tekartik layer.

## Common pitfalls

- Explicit options must be the wrapped flutter ones: a plain
  `FirebaseAppOptions` with a `projectId` throws `UnsupportedError` (before
  any native app is created).
- One app per native app: `initializeAppAsync()` called again for the default
  app, or `app()`, gives the same `FirebaseApp` with its products (since
  2026-11-10). `app(name:)` throws `UnsupportedError` (default app only).
- `delete()` throws for the default app on mobile (`firebase_core` refuses
  it).
- Unit tests: never initialize `firebase` (it needs the platform channels);
  inject `newFirebaseMemory()` of
  [tekartik_firebase_local](https://github.com/tekartik/firebase.dart/tree/main/firebase_local)
  into code written against `Firebase`.

Agent skill:
[tekartik-app-flutter-firebase-setup](skills/tekartik-app-flutter-firebase-setup/SKILL.md).
