---
name: tekartik-app-flutter-firebase-setup
description: >-
  Use when a Flutter app (Android, iOS, desktop, web) initializes Firebase
  through the Tekartik firebase abstraction with tekartik_app_flutter_firebase:
  the firebase getter (FirebaseFlutter over firebase_core),
  initializeAppAsync, FirebaseApp/App, FirebaseAppOptions/AppOptions,
  wrapOptions, projectId, firebaseAppNameDefault, nativeInstance, the
  firebase.dart import, writing code against Firebase/FirebaseApp so it also
  runs on tekartik_firebase_local in tests, and passing the app to the
  sibling firestoreService/authService getters.
---

# Firebase for Flutter apps (tekartik_app_flutter_firebase)

`tekartik_app_flutter_firebase` exposes one thing: a `firebase` getter typed
as the abstract `Firebase` of `tekartik_firebase`, resolved by conditional
import to `firebaseFlutter` (`tekartik_firebase_flutter`, backed by
`firebase_core`) on mobile, desktop and web. App code imports this package,
shared code depends on `tekartik_firebase` only and is testable with the
local/in-memory implementations.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_firebase:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_firebase
  ```
  It depends on `tekartik_firebase_flutter` (git
  `https://github.com/tekartik/firebase_flutter`, path `firebase_flutter`)
  which brings `firebase_core`. The FlutterFire platform setup is still
  yours: `google-services.json` / `GoogleService-Info.plist`, or
  `flutterfire configure` generating `firebase_options.dart`, and the web
  config for `index.html`.
* Import `package:tekartik_app_flutter_firebase/firebase.dart`. It gives the
  `firebase` getter and re-exports `package:tekartik_firebase/firebase.dart`:
  `Firebase`, `FirebaseAsync`, `FirebaseApp` (alias `App`),
  `FirebaseAppOptions` (alias `AppOptions`), `firebaseAppNameDefault`,
  `TekartikFirebaseAppExt` (`app.projectId`), `FirebaseProductService`.
* Reading `firebase` has no side effect and needs no binding; initialization
  does. On io and web it is `firebaseFlutter`; only an exotic platform hits
  the stub that throws `UnimplementedError('firebase')`.
* Initialize once, in `main()`:
  `WidgetsFlutterBinding.ensureInitialized(); var app = await
  firebase.initializeAppAsync();` uses the platform default options. Keep the
  returned `FirebaseApp` in a global or a provider; initializing the default
  app twice may throw a duplicate-app error from `firebase_core`.
* Explicit options must be wrapped: `firebase.initializeAppAsync(options:
  firebase.wrapOptions(DefaultFirebaseOptions.currentPlatform))` with the
  `FirebaseFlutterExtension` from
  `package:tekartik_firebase_flutter/firebase_flutter.dart`. A plain
  `FirebaseAppOptions` carrying a `projectId` is rejected (`'not supported
  yet'`); one without `projectId` behaves like no options.
* Synchronous `firebase.initializeApp()` only works with no `options` and no
  `name`, and only after the native default app exists (it wraps
  `Firebase.app()`); otherwise it throws. `firebase.app()` returns the
  default app; `app(name:)` throws `UnsupportedError`: Flutter here is single
  app, stick to the default one. `firebase.isLocal` is `false`.
* On the `FirebaseApp`: `name` (`firebaseAppNameDefault`, `'[DEFAULT]'`),
  `options` (`projectId`, `apiKey`, `appId`, ...), `projectId` shortcut,
  `firebase` back reference, `isLocal`. `app.nativeInstance`
  (`FirebaseAppFlutterExtension`, same import as `wrapOptions`) is the
  `firebase_core` `FirebaseApp` for FlutterFire plugins not covered by the
  Tekartik layer. `app.delete()` throws for the default app.
* Products: pass the app to the sibling packages' service getters,
  `firestoreService.firestore(app)`
  (`tekartik_app_flutter_firebase_firestore/firestore.dart`),
  `authService.auth(app)` (`tekartik_app_flutter_firebase_auth/auth.dart`),
  and the storage counterpart; they follow the same conditional-import
  pattern.
* Architecture: write services against `Firebase`/`FirebaseApp` from
  `tekartik_firebase` and inject `firebase` from `main`. In unit tests inject
  `newFirebaseMemory()` or `newFirebaseAppLocal()` from
  `tekartik_firebase_local` (git `https://github.com/tekartik/firebase.dart`,
  path `firebase_local`); never call `initializeAppAsync` on
  `firebaseFlutter` in a unit test, it needs the platform channels. The
  package's own test only checks that the `firebase` getter is reachable.

## Examples

### Initialize with the platform default options

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';

late FirebaseApp firebaseApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseApp = await firebase.initializeAppAsync();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Project ${firebaseApp.projectId}')),
      ),
    ),
  );
}
```

### Initialize with explicit (generated) options

```dart
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_firebase_flutter/firebase_flutter.dart'
    show FirebaseAppFlutterExtension, FirebaseFlutterExtension;

/// Typically `DefaultFirebaseOptions.currentPlatform` from firebase_options.dart.
const _options = core.FirebaseOptions(
  apiKey: 'api-key',
  appId: '1:123:web:abc',
  messagingSenderId: '123',
  projectId: 'my-project',
);

Future<FirebaseApp> initFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await firebase.initializeAppAsync(
    options: firebase.wrapOptions(_options),
  );
  // Native app for FlutterFire plugins outside the Tekartik layer.
  core.FirebaseApp nativeApp = app.nativeInstance;
  print('${app.name} ${app.projectId} ${nativeApp.options.projectId}');
  return app;
}
```

### Shared code against the abstraction, implementation injected

```dart
import 'package:tekartik_app_flutter_firebase/firebase.dart';

/// Depends on tekartik_firebase types only: reusable with the local
/// implementation in tests or with the node implementation on a server.
class AppContext {
  final Firebase service;
  FirebaseApp? _app;

  AppContext(this.service);

  Future<FirebaseApp> init() async =>
      _app ??= await service.initializeAppAsync();

  FirebaseApp get app => _app!;
}

Future<void> main() async {
  // In the Flutter app: the flutter implementation.
  // In tests: AppContext(newFirebaseMemory()) from tekartik_firebase_local.
  var context = AppContext(firebase);
  await context.init();
  print('${context.app.projectId} local: ${context.app.isLocal}');
}
```
