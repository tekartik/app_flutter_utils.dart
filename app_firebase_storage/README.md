# tekartik_app_flutter_firebase_storage

Firebase (Cloud) Storage for a Flutter app through the Tekartik firebase
abstraction: one `storageService` getter typed as the `StorageService`
(`FirebaseStorageService`) interface of
[tekartik_firebase_storage](https://github.com/tekartik/firebase_storage.dart/tree/main/storage),
backed by `firebase_storage` (through
[tekartik_firebase_storage_flutter](https://github.com/tekartik/firebase_flutter/tree/main/storage_flutter)).
Code written against `Storage`/`Bucket`/`File` runs unchanged on the
in-memory implementation in unit tests.

## Getting started

Not on pub.dev, add it as a git dependency, with
[tekartik_app_flutter_firebase](../app_firebase) for the `FirebaseApp`:

```yaml
dependencies:
  tekartik_app_flutter_firebase:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_firebase
  tekartik_app_flutter_firebase_storage:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_firebase_storage
```

The FlutterFire setup is still yours (`flutterfire configure`, or
`google-services.json` / `GoogleService-Info.plist` and the web
configuration), with a storage bucket and rules that allow your reads and
writes (on the web the bucket also needs a CORS configuration to read file
content).

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_app_flutter_firebase_storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await firebase.initializeAppAsync();
  var bucket = storageService.storage(app).bucket(); // the app bucket
  var file = bucket.file('notes/hello.txt');
  await file.writeAsString('Hello');
  var text = await file.readAsString();
  runApp(Center(child: Text(text, textDirection: TextDirection.ltr)));
}
```

Upload, list and download urls in [example/main.dart](example/main.dart).

## Platforms

Android, iOS, macOS, web and Windows (the `firebase_core` platforms). Linux
has no `firebase_core` implementation: `initializeAppAsync` fails there.

## What to use

- `storageService` (`StorageService`): `storage(app)` gives the `Storage`
  of an app of `firebase`, one per app (cached, also reachable with
  `app.storage()` afterwards).
- `Storage`: `bucket([name])` (the app bucket by default) and `ref(path)`
  (`getDownloadUrl()`, for `Image.network`).
- `Bucket`: `file(path)`, `getFiles(GetFilesOptions(prefix:, maxResults:,
  autoPaginate:))`.
- `File`: `upload(bytes, options: StorageUploadFileOptions(contentType:,
  cacheControl:))`, `writeAsBytes`, `writeAsString`, `readAsBytes`,
  `readAsString`, `exists()`, `delete()`, `getMetadata()` (size, md5,
  content type, update time).
- `package:tekartik_app_flutter_firebase_storage/storage_utils.dart`:
  `firebaseStorageGetAdminWebUploadFolder(projectId, bucketName, path)` and
  `bucket.getAdminWebUploadFolder(app, path)`, a Firebase console url (for
  an admin screen).

## Common pitfalls

- `File.metadata` is always null on Flutter: call `getMetadata()`.
- `File.exists()` is false on any error (permission denied, network), not
  only for a missing file: do not overwrite on a false `exists()` alone.
- `Bucket.exists()` only compares the name with the app bucket, and
  `Bucket.create()` throws: buckets are created in the console.
- Hand `Image.network` the url of `storage.ref(path).getDownloadUrl()`, not
  a `gs://` path.
- The app must come from `firebase` of tekartik_app_flutter_firebase: an app
  of another implementation is rejected (assert).
- Unit tests: never use `storageService` (it needs the platform channels);
  inject `newStorageMemory()` of
  [tekartik_firebase_storage_fs](https://github.com/tekartik/firebase_storage.dart/tree/main/storage_fs)
  into code written against `Storage`.

Agent skill:
[tekartik-app-flutter-firebase-storage-setup](skills/tekartik-app-flutter-firebase-storage-setup/SKILL.md).
