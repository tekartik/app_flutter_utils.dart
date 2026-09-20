---
name: tekartik-app-flutter-firebase-auth-setup
description: >-
  Use when adding Firebase authentication to a Flutter app (mobile, desktop or
  web) through tekartik_app_flutter_firebase_auth: the single
  package:tekartik_app_flutter_firebase_auth/auth.dart import, the global
  authService getter (FirebaseAuthService / AuthService),
  authService.auth(app), FirebaseAuth, signInWithEmailAndPassword,
  createUserWithEmailAndPassword, signInOrUpWithEmailAndPassword,
  signInAnonymously, signOut, currentUser, onCurrentUser,
  sendEmailVerification, FirebaseUser/User, UserCredential, and how it pairs
  with firebase.initializeAppAsync() from tekartik_app_flutter_firebase.
---

# Firebase auth for a Flutter app (tekartik_app_flutter_firebase_auth)

This package is a one-getter glue package: it binds the abstract
`tekartik_firebase_auth` API to the Flutter (FlutterFire) implementation so
app code never imports a platform specific auth package. It adds nothing else.

## Guidelines

* Dependency (git, not on pub.dev). Add the firebase app package too, you
  need it to get a `FirebaseApp`:
  ```yaml
  dependencies:
    tekartik_app_flutter_firebase_auth:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_firebase_auth
      version: '>=0.1.0'
    tekartik_app_flutter_firebase:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_firebase
      version: '>=0.1.0'
  ```
* One public library: `package:tekartik_app_flutter_firebase_auth/auth.dart`.
  It re-exports `package:tekartik_firebase_auth/auth.dart` (which itself
  re-exports `package:tekartik_firebase/firebase.dart`, so `FirebaseApp`,
  `App`, `AppOptions` come along) and adds a single top level getter:
  `AuthService get authService`. Do not import anything under `lib/src/`.
* `authService` is resolved by conditional import: `dart:io` and
  `dart:js_interop` builds both return `authServiceFlutter` from
  `tekartik_firebase_auth_flutter`; any other target gets a stub whose getter
  throws `UnimplementedError`. Importing the library is always safe, reading
  `authService` is what can throw.
* `AuthService` is a deprecated alias for `FirebaseAuthService`, `Auth` for
  `FirebaseAuth`, `User` for `FirebaseUser`. Prefer the `Firebase*` names in
  new code; both resolve to the same types.
* Get the app first, then the auth instance:
  `var app = await firebase.initializeAppAsync();` (from
  `package:tekartik_app_flutter_firebase/firebase.dart`), then
  `var auth = authService.auth(app);`. `auth(app)` caches one `FirebaseAuth`
  per app and registers it as a product of the app, so `app.auth()`
  (`TekartikFirebaseAuthFirebaseAppExt`) and `FirebaseAuth.instance` work
  afterwards. Call `WidgetsFlutterBinding.ensureInitialized()` before
  `initializeAppAsync`.
* `firebase.initializeAppAsync()` calls FlutterFire's
  `Firebase.initializeApp()` for you: the native config
  (`google-services.json`, `GoogleService-Info.plist`, web `firebase-config`)
  is what selects the project. The synchronous `firebase.initializeApp()`
  only works once the native app already exists.
* Sign-in surface actually implemented by the Flutter service:
  `signInWithEmailAndPassword(email:, password:)`,
  `createUserWithEmailAndPassword(email:, password:)`,
  `signInAnonymously()`, `signOut()`, `sendEmailVerification()`,
  `currentUser`, `reloadCurrentUser()`, `onCurrentUser` and
  `signIn(AuthProvider, options:)`. The extension
  `signInOrUpWithEmailAndPassword(email:, password:)` signs in and falls back
  to creating the account; `getOrCreateUserWithEmailAndPassword(...)` does the
  same but signs out again and returns the `FirebaseUser`.
* Admin-only members (`listUsers`, `getUser`, `getUserByEmail`,
  `verifyIdToken`) are not available here: the Flutter service reports
  `supportsListUsers == false` and throws. Check
  `authService.supportsListUsers` / `authService.supportsCurrentUser` before
  branching on them. Server-side user administration belongs in a backend
  using `tekartik_firebase_auth_rest`/`_node`, not in the app.
* `onCurrentUser` is a broadcast stream that emits the current `FirebaseUser?`
  (null when signed out); it is the right source for a `StreamBuilder` gate
  between a sign-in page and the app. `currentUser` is the synchronous
  snapshot and is null until the native SDK has restored the session.
* Emulator and native escape hatches (`useAuthEmulator(host, port)`,
  `nativeInstance`, `webSetIndexedDbPersistence()`) live in
  `package:tekartik_firebase_auth_flutter/auth_flutter.dart`, not in this
  package: import it explicitly (and declare it in `pubspec.yaml`) when you
  need them.
* Testing: this package cannot be unit tested off-device; the package's own
  test only checks that the symbols exist and swallows the
  `UnimplementedError`. For logic tests, depend on the abstract
  `tekartik_firebase_auth` API in your code and inject a local service
  (`tekartik_firebase_auth_local` / `_sembast`) in tests instead of
  `authService`.

## Examples

### App startup: firebase app + auth instance

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_app_flutter_firebase_auth/auth.dart';

late final FirebaseApp firebaseApp;
late final FirebaseAuth firebaseAuth;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseApp = await firebase.initializeAppAsync();
  firebaseAuth = authService.auth(firebaseApp);
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('app')))));
}
```

### Email/password sign in, sign up and sign out

```dart
import 'package:tekartik_app_flutter_firebase_auth/auth.dart';

Future<User> signIn(FirebaseAuth auth, String email, String password) async {
  var credential = await auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return credential.user;
}

Future<User> signUp(FirebaseAuth auth, String email, String password) async {
  var credential = await auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  await auth.sendEmailVerification();
  return credential.user;
}

/// Sign in, creating the account on the fly if needed.
Future<User> signInOrUp(FirebaseAuth auth, String email, String password) async {
  var credential = await auth.signInOrUpWithEmailAndPassword(
    email: email,
    password: password,
  );
  return credential.user;
}

Future<void> signOut(FirebaseAuth auth) => auth.signOut();
```

### Gate the UI on the current user

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_firebase_auth/auth.dart';

class AuthGate extends StatelessWidget {
  final FirebaseAuth auth;
  final Widget signedIn;
  final Widget signedOut;

  const AuthGate({
    super.key,
    required this.auth,
    required this.signedIn,
    required this.signedOut,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.onCurrentUser,
      initialData: auth.currentUser,
      builder: (context, snapshot) {
        var user = snapshot.data;
        if (user == null) {
          return signedOut;
        }
        return signedIn;
      },
    );
  }
}
```

### Anonymous session, upgraded later

```dart
import 'package:tekartik_app_flutter_firebase_auth/auth.dart';

/// Makes sure some user exists, anonymous if nobody signed in yet.
Future<User> ensureUser(FirebaseAuth auth) async {
  var user = auth.currentUser;
  if (user != null) {
    return user;
  }
  var credential = await auth.signInAnonymously();
  return credential.user;
}

void dumpUser(User user) {
  print('uid: ${user.uid}');
  print('anonymous: ${user.isAnonymous}');
  print('email: ${user.email} verified: ${user.emailVerified}');
  print('display name: ${user.displayName}');
}
```

### Guarding the platform stub

```dart
import 'package:tekartik_app_flutter_firebase_auth/auth.dart';

/// Null when running on a target without a flutter auth implementation.
AuthService? get authServiceOrNull {
  try {
    return authService;
  } on UnimplementedError catch (_) {
    return null;
  }
}
```

## Common mistakes

* Calling `authService.auth(app)` with an app created by another `Firebase`
  implementation (a local/sembast one): the flutter service asserts the app is
  a `FirebaseAppFlutter`.
* Using the synchronous `firebase.initializeApp()` before FlutterFire's own
  `Firebase.initializeApp()` ran.
* Expecting `listUsers` / `getUserByEmail` / `verifyIdToken` to work in the
  app: they are admin APIs, unsupported here.
* Reading `currentUser` right after startup and concluding the user is signed
  out: wait for the first `onCurrentUser` event.
* Importing `package:tekartik_app_flutter_firebase_auth/src/firebase_auth.dart`
  (or the `_io`/`_web` variants) instead of the public `auth.dart`.
