---
name: tekartik-app-flutter-firebase-storage-setup
description: >-
  Use when uploading, downloading or listing Firebase Storage files from a
  Flutter app (mobile, desktop or web) through
  tekartik_app_flutter_firebase_storage: the
  package:tekartik_app_flutter_firebase_storage/storage.dart import, the global
  storageService getter (StorageService/FirebaseStorageService),
  storageService.storage(app), Storage/FirebaseStorage, bucket(), ref(),
  Bucket.file/getFiles/exists, File.upload/writeAsBytes/writeAsString/
  readAsBytes/readAsString/download/delete/getMetadata, FileMetadata,
  StorageUploadFileOptions, GetFilesOptions, GetFilesResponse,
  Reference.getDownloadUrl, and the storage_utils.dart
  firebaseStorageGetAdminWebUploadFolder / getAdminWebUploadFolder helpers.
---

# Firebase storage for a Flutter app (tekartik_app_flutter_firebase_storage)

This package binds the abstract `tekartik_firebase_storage` API to the
FlutterFire `firebase_storage` implementation, so app code never imports a
platform specific storage package. It adds one getter plus a small
console-url helper.

## Guidelines

* Dependency (git, not on pub.dev). Add the firebase app package too, you
  need it to get a `FirebaseApp`:
  ```yaml
  dependencies:
    tekartik_app_flutter_firebase_storage:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_firebase_storage
      version: '>=0.1.0'
    tekartik_app_flutter_firebase:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_firebase
      version: '>=0.1.0'
  ```
* Two public libraries:
  * `package:tekartik_app_flutter_firebase_storage/storage.dart` re-exports
    `package:tekartik_firebase_storage/storage.dart` (and through it
    `package:tekartik_firebase/firebase.dart`) and adds
    `StorageService get storageService`.
  * `package:tekartik_app_flutter_firebase_storage/storage_utils.dart` adds
    `firebaseStorageGetAdminWebUploadFolder(projectId, bucketName, path)` and
    the `Bucket.getAdminWebUploadFolder(firebaseApp, path)` extension
    (`AppFirebaseStorageBucketExt`), which build a Firebase console url. It
    does not re-export `storage.dart`, so import both when you use it.
  Never import anything under `lib/src/`.
* `storageService` is resolved by conditional import: `dart:io` and
  `dart:js_interop` builds both return `storageServiceFlutter` from
  `tekartik_firebase_storage_flutter`; any other target gets a stub whose
  getter throws `UnimplementedError`. Importing is safe everywhere, reading
  the getter is what can throw.
* Startup order: `WidgetsFlutterBinding.ensureInitialized()`, then
  `var app = await firebase.initializeAppAsync();` (from
  `package:tekartik_app_flutter_firebase/firebase.dart`), then
  `var storage = storageService.storage(app);`. `storage(app)` caches one
  instance per app and registers it as a product, so `app.storage()`
  (`TekartikFirebaseStorageFirebaseAppExt`) and `FirebaseStorage.instance`
  work afterwards.
* Two access styles, both from `Storage` (alias of `FirebaseStorage`):
  * `bucket([name])` returns a `Bucket` - `name` defaults to the app's
    configured bucket. `bucket.file(path)` gives a `File` for read/write,
    `bucket.getFiles([GetFilesOptions(prefix:, maxResults:, autoPaginate:,
    pageToken:)])` lists, `bucket.exists()` only checks the bucket name
    matches the app's bucket.
  * `ref([path])` returns a `Reference`, whose only member is
    `getDownloadUrl()`. `path` may be a plain path or a `gs://` url; empty or
    omitted means the root.
* `File` operations: `upload(bytes, options: StorageUploadFileOptions(
  contentType: 'image/png'))`, `writeAsBytes(bytes)`, `writeAsString(text)`,
  `save(content)`, `readAsBytes()` / `download()`, `readAsString()`,
  `exists()`, `delete()`, `getMetadata()` and the cached `metadata`. `name`
  is the path inside the bucket, `bucket` the owning bucket. Bytes are
  `Uint8List` (`dart:typed_data`).
* `FileMetadata` exposes `size`, `dateUpdated`, `md5Hash` and `contentType`.
  It is only populated after `getMetadata()`.
* Not supported by the flutter backend: `Bucket.create()` throws
  `UnimplementedError` (create buckets from the console or a backend), and
  `Bucket.exists()` is a name comparison, not a real server check.
* To hand a url to a widget (`Image.network`), use
  `storage.ref(path).getDownloadUrl()`, not the `gs://` path.
* Testing: this package throws off-device. Write your code against the
  abstract `Storage`/`Bucket`/`File` types and inject the instance, so tests
  can use an in-memory implementation
  (`tekartik_firebase_storage_local`/`_fs`) instead of `storageService`.
  `firebaseStorageGetAdminWebUploadFolder` is pure and can be unit tested
  directly.

## Examples

### App startup: firebase app + storage bucket

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_app_flutter_firebase_storage/storage.dart';

late final FirebaseApp firebaseApp;
late final Storage storage;
late final Bucket bucket;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseApp = await firebase.initializeAppAsync();
  storage = storageService.storage(firebaseApp);
  bucket = storage.bucket(); // default bucket of the app
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('app')))));
}
```

### Upload, read back, delete

```dart
import 'dart:typed_data';

import 'package:tekartik_app_flutter_firebase_storage/storage.dart';

Future<void> uploadAvatar(Bucket bucket, String uid, Uint8List png) async {
  var file = bucket.file('users/$uid/avatar.png');
  await file.upload(
    png,
    options: StorageUploadFileOptions(contentType: 'image/png'),
  );
  var metadata = await file.getMetadata();
  print('${file.name}: ${metadata.size} bytes, ${metadata.contentType}');
}

Future<String?> readNote(Bucket bucket, String path) async {
  var file = bucket.file(path);
  if (!await file.exists()) {
    return null;
  }
  return await file.readAsString();
}

Future<void> writeNote(Bucket bucket, String path, String text) =>
    bucket.file(path).writeAsString(text);

Future<void> removeNote(Bucket bucket, String path) =>
    bucket.file(path).delete();
```

### Download url in a widget

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_firebase_storage/storage.dart';

class StorageImage extends StatelessWidget {
  final Storage storage;
  final String path;

  const StorageImage({super.key, required this.storage, required this.path});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: storage.ref(path).getDownloadUrl(),
      builder: (context, snapshot) {
        var url = snapshot.data;
        if (url == null) {
          return const SizedBox.shrink();
        }
        return Image.network(url);
      },
    );
  }
}
```

### List files under a prefix, page by page

```dart
import 'package:tekartik_app_flutter_firebase_storage/storage.dart';

Future<List<String>> listUserFiles(Bucket bucket, String uid) async {
  var names = <String>[];
  GetFilesOptions? options = GetFilesOptions(
    prefix: 'users/$uid/',
    maxResults: 100,
    autoPaginate: false,
  );
  while (options != null) {
    var response = await bucket.getFiles(options);
    for (var file in response.files) {
      names.add(file.name);
    }
    options = response.nextQuery;
  }
  return names;
}
```

### Link to the file in the Firebase console

```dart
import 'package:tekartik_app_flutter_firebase_storage/storage.dart';
import 'package:tekartik_app_flutter_firebase_storage/storage_utils.dart';

/// Handy for an admin/debug screen.
String consoleUrl(FirebaseApp app, Bucket bucket, String path) =>
    bucket.getAdminWebUploadFolder(app, path);

String consoleUrlRaw(String projectId, String bucketName, String path) =>
    firebaseStorageGetAdminWebUploadFolder(projectId, bucketName, path);
```

## Common mistakes

* Passing `storageService.storage(app)` an app created by another `Firebase`
  implementation (local/sembast): the flutter service asserts the app is a
  `FirebaseAppFlutter`.
* Calling `bucket.create()` on the flutter backend: it throws.
* Trusting `bucket.exists()` as a server check - it only compares names.
* Feeding a `gs://` path to `Image.network`: resolve it with
  `storage.ref(path).getDownloadUrl()` first.
* Reading `file.metadata` before `getMetadata()` has run.
* Importing `package:tekartik_app_flutter_firebase_storage/src/storage.dart`
  instead of the public `storage.dart`.
