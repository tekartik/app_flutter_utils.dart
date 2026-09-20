---
name: tekartik-app-flutter-firebase-firestore-setup
description: >-
  Use when reading or writing Cloud Firestore from a Flutter app (mobile,
  desktop or web) through tekartik_app_flutter_firebase_firestore: the
  package:tekartik_app_flutter_firebase_firestore/firestore.dart import, the
  global firestoreService getter (FirestoreService),
  firestoreService.firestore(app), Firestore, CollectionReference,
  DocumentReference, DocumentSnapshot, QuerySnapshot, Query.where/orderBy/limit,
  onSnapshot streams, runTransaction, WriteBatch, FieldValue.serverTimestamp,
  Timestamp, and the supportsXxx capability flags of the flutter backend.
---

# Firestore for a Flutter app (tekartik_app_flutter_firebase_firestore)

This package is a one-getter glue package: it binds the abstract
`tekartik_firebase_firestore` API to the FlutterFire `cloud_firestore`
implementation so app code never imports a platform specific firestore
package, and can be swapped for an in-memory/sembast firestore in tests.

## Guidelines

* Dependency (git, not on pub.dev). Add the firebase app package too, you
  need it to get a `FirebaseApp`:
  ```yaml
  dependencies:
    tekartik_app_flutter_firebase_firestore:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_firebase_firestore
      version: '>=0.1.0'
    tekartik_app_flutter_firebase:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_firebase
      version: '>=0.1.0'
  ```
* One public library:
  `package:tekartik_app_flutter_firebase_firestore/firestore.dart`. It
  re-exports `package:tekartik_firebase_firestore/firestore.dart` (and through
  it `package:tekartik_firebase/firebase.dart`, so `FirebaseApp`/`App` come
  along) and adds a single top level getter:
  `FirestoreService get firestoreService`. Never import anything under
  `lib/src/`.
* `firestoreService` is resolved by conditional import: `dart:io` and
  `dart:js_interop` builds both return `firestoreServiceFlutter` from
  `tekartik_firebase_firestore_flutter`; any other target gets a stub whose
  getter throws `UnimplementedError`. Importing is always safe, reading the
  getter is what can throw.
* Startup order: `WidgetsFlutterBinding.ensureInitialized()`, then
  `var app = await firebase.initializeAppAsync();` (from
  `package:tekartik_app_flutter_firebase/firebase.dart`), then
  `var firestore = firestoreService.firestore(app);`. `firestore(app)` caches
  one instance per app and registers it as a product, so `app.firestore()`
  (`TekartikFirestoreFirebaseAppExt`) and `Firestore.instance` work after it.
* Core API on `Firestore`: `collection(path)` (odd number of segments),
  `doc(path)` (even number of segments), `collectionGroup(id)`, `batch()`,
  `runTransaction(action)`, `getAll(refs)`, `listCollections()`,
  `service`.
* `DocumentReference`: `get()`, `set(data, [SetOptions(merge: true)])`,
  `update(data)`, `delete()`, `onSnapshot()`, `id`, `path`, `parent`,
  `collection(path)`. `CollectionReference` extends `Query` and adds
  `doc(path)` and `add(data)` (auto id).
* `Query`: `where(fieldPath, isEqualTo:, isLessThan:, isLessThanOrEqualTo:,
  isGreaterThan:, isGreaterThanOrEqualTo:, arrayContains:, arrayContainsAny:,
  whereIn:, isNull:)`, `orderBy(key, descending:)`, `orderById()`,
  `limit(n)`, `startAt/startAfter/endAt/endBefore(values:)`, `get()`,
  `count()`, `onCount()`, `onSnapshot()`, `aggregate(fields)`.
* Data is plain `Map<String, Object?>`. `DocumentSnapshot` exposes `exists`,
  `data`, `ref`, `metadata` (and `dataOrNull` from `DocumentSnapshotExt`);
  `QuerySnapshot` exposes `docs`, `documentChanges` and, through
  `QuerySnapshotExtension`, `refs` and `ids`. Field helpers:
  `FieldValue.serverTimestamp`, `FieldValue.delete`,
  `FieldValue.arrayUnion([...])`, `FieldValue.arrayRemove([...])`,
  `Timestamp`, `Blob`, `GeoPoint`, `VectorValue`, `DocumentData` (typed
  getters/setters over a map).
* Know the flutter backend limits before using a feature: this service has
  `supportsQuerySelect == false` (`Query.select` is a no-op),
  `supportsQuerySnapshotCursor == false` (paginate with
  `startAfter(values: [...])`, not with a snapshot),
  `supportsDocumentSnapshotTime == false` (`updateTime`/`createTime` are
  null), `supportsListCollections == false` (`listCollections()` throws).
  `supportsTimestamps`, `supportsFieldValueArray`, `supportsAggregateQueries`,
  `supportsBlobs`, `supportsVectorValue` and `supportsTrackChanges` are all
  true.
* The emulator hook (`useFirestoreEmulator(host, port)` on `FirestoreFlutter`)
  lives in `package:tekartik_firebase_firestore_flutter/firestore_flutter.dart`,
  not here: import and declare that package explicitly when you need it.
* Testing: write your data layer against the abstract `Firestore` type and
  inject it. In unit tests use an in-memory service
  (`newFirestoreServiceMemory()` from `tekartik_firebase_firestore_sembast`
  with `newFirebaseAppLocal()`) instead of `firestoreService`, which throws
  off-device.

## Examples

### App startup: firebase app + firestore instance

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_app_flutter_firebase_firestore/firestore.dart';

late final FirebaseApp firebaseApp;
late final Firestore firestore;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseApp = await firebase.initializeAppAsync();
  firestore = firestoreService.firestore(firebaseApp);
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('app')))));
}
```

### Read, write and query

```dart
import 'package:tekartik_app_flutter_firebase_firestore/firestore.dart';

Future<void> crud(Firestore firestore) async {
  var notes = firestore.collection('notes');

  // Create with an auto id.
  var ref = await notes.add({
    'title': 'hello',
    'done': false,
    'updated': FieldValue.serverTimestamp,
  });

  // Read one document.
  var snapshot = await ref.get();
  if (snapshot.exists) {
    print(snapshot.data['title']);
  }

  // Merge some fields, then update.
  await ref.set({'title': 'hello world'}, SetOptions(merge: true));
  await ref.update({'done': true});

  // Query.
  var query = notes
      .where('done', isEqualTo: false)
      .orderBy('updated', descending: true)
      .limit(20);
  var querySnapshot = await query.get();
  for (var doc in querySnapshot.docs) {
    print('${doc.ref.id}: ${doc.data}');
  }
  print('ids: ${querySnapshot.ids}, count: ${await query.count()}');

  await ref.delete();
}
```

### Live list widget on a query

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_firebase_firestore/firestore.dart';

class NoteListView extends StatelessWidget {
  final Firestore firestore;

  const NoteListView({super.key, required this.firestore});

  @override
  Widget build(BuildContext context) {
    var query = firestore.collection('notes').orderBy('title');
    return StreamBuilder<QuerySnapshot>(
      stream: query.onSnapshot(),
      builder: (context, snapshot) {
        var docs = snapshot.data?.docs ?? <DocumentSnapshot>[];
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var doc = docs[index];
            return ListTile(
              title: Text(doc.data['title']?.toString() ?? doc.ref.id),
            );
          },
        );
      },
    );
  }
}
```

### Transaction and write batch

```dart
import 'package:tekartik_app_flutter_firebase_firestore/firestore.dart';

/// Atomically increments a counter field.
Future<int> increment(Firestore firestore, String path) async {
  return await firestore.runTransaction((transaction) async {
    var ref = firestore.doc(path);
    var snapshot = await transaction.get(ref);
    var value = (snapshot.exists ? snapshot.data['count'] as int? : null) ?? 0;
    var newValue = value + 1;
    transaction.set(ref, {'count': newValue}, SetOptions(merge: true));
    return newValue;
  });
}

/// Writes many documents as one atomic unit.
Future<void> importAll(Firestore firestore, Map<String, Object?> byId) async {
  var batch = firestore.batch();
  for (var entry in byId.entries) {
    batch.set(firestore.doc('notes/${entry.key}'), {
      'title': entry.value,
      'updated': FieldValue.serverTimestamp,
    });
  }
  await batch.commit();
}
```

### Paginating without snapshot cursors

```dart
import 'package:tekartik_app_flutter_firebase_firestore/firestore.dart';

/// The flutter backend has supportsQuerySnapshotCursor == false, so page on
/// the ordered field values, not on a DocumentSnapshot.
Future<void> pageByTitle(Firestore firestore) async {
  var pageSize = 50;
  Object? lastTitle;
  while (true) {
    var query = firestore.collection('notes').orderBy('title').limit(pageSize);
    if (lastTitle != null) {
      query = query.startAfter(values: [lastTitle]);
    }
    var snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      break;
    }
    for (var doc in snapshot.docs) {
      print(doc.ref.path);
    }
    lastTitle = snapshot.docs.last.data['title'];
    if (snapshot.docs.length < pageSize) {
      break;
    }
  }
}
```

## Common mistakes

* Passing `firestoreService.firestore(app)` an app created by another
  `Firebase` implementation (local/sembast): the flutter service asserts the
  app is a `FirebaseAppFlutter`.
* Mixing up `collection()` (odd segment count) and `doc()` (even segment
  count) paths.
* Using `startAfter(snapshot: ...)` or `Query.select` on the flutter backend:
  both are unsupported there.
* Reading `DocumentSnapshot.data` without checking `exists` first (use
  `dataOrNull`).
* Writing `FieldValue.serverTimestamp()` - it is a static *value*,
  `FieldValue.serverTimestamp`, not a function call.
* Importing `package:tekartik_app_flutter_firebase_firestore/src/firestore.dart`
  instead of the public `firestore.dart`.
