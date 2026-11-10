/// Firebase for a Flutter app: the [firebase] getter, the `Firebase`
/// interface of tekartik_firebase backed by `firebase_core` on Android, iOS,
/// macOS, Windows and the web.
///
/// Re-exports `package:tekartik_firebase/firebase.dart` (`Firebase`,
/// `FirebaseApp`, `FirebaseAppOptions`...).
library;

import 'package:tekartik_app_flutter_firebase/src/firebase.dart';

import 'src/firebase.dart' as src;

export 'package:tekartik_app_flutter_firebase/src/firebase.dart';

/// The app firebase for flutter (`firebaseFlutter` of
/// tekartik_firebase_flutter).
///
/// Reading it has no side effect; initialize the default app once with
/// `firebase.initializeAppAsync()` after
/// `WidgetsFlutterBinding.ensureInitialized()`. Throws `UnimplementedError`
/// on a platform with neither `dart:io` nor `dart:js_interop`.
Firebase get firebase => src.firebase;
