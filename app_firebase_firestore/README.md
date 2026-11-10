# tekartik_app_flutter_firebase_firestore

Cloud Firestore for a Flutter app through the Tekartik firebase abstraction:
one `firestoreService` getter typed as the `FirestoreService` interface of
[tekartik_firebase_firestore](https://github.com/tekartik/firebase_firestore.dart/tree/main/firestore),
backed by `cloud_firestore` (through
[tekartik_firebase_firestore_flutter](https://github.com/tekartik/firebase_flutter/tree/main/firestore_flutter)).
Code written against `Firestore` runs unchanged on the in-memory (sembast)
implementation in unit tests.

## Getting started

Not on pub.dev, add it as a git dependency, with
[tekartik_app_flutter_firebase](../app_firebase) for the `FirebaseApp`:

```yaml
dependencies:
  tekartik_app_flutter_firebase:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_firebase
  tekartik_app_flutter_firebase_firestore:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_firebase_firestore
```

The FlutterFire setup is still yours (`flutterfire configure`, or
`google-services.json` / `GoogleService-Info.plist` and the web
configuration), with a Firestore database and rules that allow your reads
and writes.

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_app_flutter_firebase_firestore/firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await firebase.initializeAppAsync();
  var firestore = firestoreService.firestore(app);
  var ref = firestore.doc('notes/hello');
  await ref.set({'title': 'Hello', 'updated': FieldValue.serverTimestamp});
  var snapshot = await ref.get();
  runApp(
    Center(
      child: Text(
        '${snapshot.data['title']}',
        textDirection: TextDirection.ltr,
      ),
    ),
  );
}
```

A live list of documents in [example/main.dart](example/main.dart).

## Platforms

Android, iOS, macOS, web and Windows (the `firebase_core` platforms). Linux
has no `firebase_core` implementation: `initializeAppAsync` fails there.

## What to use

- `firestoreService` (`FirestoreService`): `firestore(app)` gives the
  `Firestore` of an app of `firebase`, one per app (cached, also reachable
  with `app.firestore()` afterwards).
- `Firestore`: `collection(path)`, `doc(path)`, `collectionGroup(id)`,
  `batch()`, `runTransaction(action)`, `getAll(refs)`.
- `DocumentReference`: `get()`, `set(data, [SetOptions(merge: true)])`,
  `update(data)`, `delete()`, `onSnapshot()`. `CollectionReference` adds
  `add(data)` (generated id) to `Query`: `where`, `orderBy`, `limit`,
  `startAfter`/`startAt`/`endAt`/`endBefore` (values or a snapshot),
  `get()`, `onSnapshot()`, `count()`.
- Values: `FieldValue.serverTimestamp` (a value, not a function),
  `FieldValue.delete`, `FieldValue.arrayUnion([...])`, `Timestamp`, `Blob`,
  `GeoPoint`.
- The emulator and the `cloud_firestore` instance live in
  `package:tekartik_firebase_firestore_flutter/firestore_flutter.dart`
  (declare it).

## Common pitfalls

- `collection()` takes a path with an odd number of segments, `doc()` an
  even one.
- `DocumentSnapshot.data` of a missing document: check `exists` first (or
  use `dataOrNull`).
- Not supported by the Flutter backend: `Query.select` (no effect,
  `supportsQuerySelect` is false), `updateTime`/`createTime` of a snapshot
  (null), `listCollections()`.
- The app must come from `firebase` of tekartik_app_flutter_firebase: an app
  of another implementation is rejected (assert).
- Unit tests: never use `firestoreService` (it needs the platform channels);
  inject `newFirestoreServiceMemory().firestore(newFirebaseAppLocal())` into
  code written against `Firestore`
  ([tekartik_firebase_firestore_sembast](https://github.com/tekartik/firebase_firestore.dart/tree/main/firestore_sembast)
  and [tekartik_firebase_local](https://github.com/tekartik/firebase.dart/tree/main/firebase_local)).

Agent skill:
[tekartik-app-flutter-firebase-firestore-setup](skills/tekartik-app-flutter-firebase-firestore-setup/SKILL.md).
