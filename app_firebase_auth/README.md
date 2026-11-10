# tekartik_app_flutter_firebase_auth

Firebase Authentication for a Flutter app through the Tekartik firebase
abstraction: one `authService` getter typed as the `FirebaseAuthService`
interface of
[tekartik_firebase_auth](https://github.com/tekartik/firebase_auth.dart/tree/main/auth),
backed by `firebase_auth` (through
[tekartik_firebase_auth_flutter](https://github.com/tekartik/firebase_flutter/tree/main/auth_flutter)).
Code written against `FirebaseAuth` runs unchanged on a local implementation
in unit tests.

## Getting started

Not on pub.dev, add it as a git dependency, with
[tekartik_app_flutter_firebase](../app_firebase) for the `FirebaseApp`:

```yaml
dependencies:
  tekartik_app_flutter_firebase:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_firebase
  tekartik_app_flutter_firebase_auth:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_firebase_auth
```

The FlutterFire setup is still yours (`flutterfire configure`, or
`google-services.json` / `GoogleService-Info.plist` and the web
configuration), and the sign-in methods you use must be enabled in the
Firebase console.

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_app_flutter_firebase_auth/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await firebase.initializeAppAsync();
  var auth = authService.auth(app);
  runApp(
    MaterialApp(
      home: Scaffold(
        body: StreamBuilder<FirebaseUser?>(
          stream: auth.onCurrentUser,
          builder: (context, snapshot) =>
              Center(child: Text(snapshot.data?.uid ?? 'Signed out')),
        ),
      ),
    ),
  );
}
```

Complete app (anonymous sign in, sign out) in
[example/main.dart](example/main.dart).

## Platforms

Android, iOS, macOS, web and Windows (the `firebase_core` platforms). Linux
has no `firebase_core` implementation: `initializeAppAsync` fails there.

## What to use

- `authService` (`FirebaseAuthService`, old name `AuthService`):
  `auth(app)` gives the `FirebaseAuth` of an app of `firebase`, one per app
  (cached, also reachable with `app.auth()` afterwards).
- `FirebaseAuth`: `signInWithEmailAndPassword`,
  `createUserWithEmailAndPassword`, `signInAnonymously`, `signOut`,
  `sendEmailVerification`, `sendPasswordResetEmail`, `reloadCurrentUser`,
  `currentUser` and `onCurrentUser` (a stream of `FirebaseUser?`, null when
  signed out). `signInOrUpWithEmailAndPassword` (extension) signs in and
  creates the account when it does not exist.
- The emulator and the `firebase_auth` instance live in
  `package:tekartik_firebase_auth_flutter/auth_flutter.dart` (declare it):
  `auth.flutter.useAuthEmulator(host, port)` before any sign in,
  `auth.nativeInstance`.

## Common pitfalls

- `currentUser` is null until the native SDK restored the session: wait for
  the first `onCurrentUser` event before showing a sign-in page.
- `signIn(AuthProvider)` (Google, Apple...) throws `UnsupportedError` here:
  use the FlutterFire provider API on `nativeInstance`.
- Admin calls (`listUsers`, `getUser`, `verifyIdToken`) are not supported in
  an app (`authService.supportsListUsers` is false): they belong to a
  backend.
- The app must come from `firebase` of tekartik_app_flutter_firebase: an app
  of another implementation (local, sembast) is rejected (assert).
- Unit tests: never use `authService` (it needs the platform channels);
  inject `authServiceLocal` of
  [tekartik_firebase_auth_local](https://github.com/tekartik/firebase_auth.dart/tree/main/auth_local)
  with `newFirebaseAppLocal()` into code written against `FirebaseAuth`.

Agent skill:
[tekartik-app-flutter-firebase-auth-setup](skills/tekartik-app-flutter-firebase-auth-setup/SKILL.md).
