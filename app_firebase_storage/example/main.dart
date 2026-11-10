// Uploads a text file, lists the `example/` folder and shows each file with
// its size and download url (FlutterFire setup done: `flutterfire
// configure`, or google-services.json / GoogleService-Info.plist, and
// storage rules allowing it).
import 'dart:convert';
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_app_flutter_firebase_storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Storage? storage;
  Object? error;
  try {
    var app = await firebase.initializeAppAsync();
    storage = storageService.storage(app);
  } catch (e) {
    // No FlutterFire configuration (or Linux, not supported).
    error = e;
  }
  runApp(
    MaterialApp(
      home: storage == null
          ? Scaffold(
              body: Center(child: Text('Firebase not available: $error')),
            )
          : FilesPage(storage: storage),
    ),
  );
}

/// One listed file.
class FileInfo {
  /// Its path in the bucket.
  final String name;

  /// Its size in bytes.
  final int size;

  /// Its download url (null when it cannot be read, e.g. no rules for it).
  final String? url;

  /// One listed file.
  FileInfo(this.name, this.size, this.url);
}

/// Written against [Storage]: a test passes an in-memory one
/// (tekartik_firebase_storage_fs `newStorageMemory()`) instead.
Future<List<FileInfo>> uploadAndList(Storage storage) async {
  var bucket = storage.bucket();
  await bucket
      .file('example/hello.txt')
      .upload(
        Uint8List.fromList(utf8.encode('Hello ${DateTime.now()}')),
        options: StorageUploadFileOptions(contentType: 'text/plain'),
      );
  var response = await bucket.getFiles(GetFilesOptions(prefix: 'example/'));
  var infos = <FileInfo>[];
  for (var file in response.files) {
    var metadata = await file.getMetadata();
    String? url;
    try {
      url = await storage.ref(file.name).getDownloadUrl();
    } catch (_) {}
    infos.add(FileInfo(file.name, metadata.size, url));
  }
  return infos;
}

/// Shows the files of `example/` after an upload.
class FilesPage extends StatefulWidget {
  /// The storage to use.
  final Storage storage;

  /// Shows the files of `example/` after an upload.
  const FilesPage({super.key, required this.storage});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  /// Started once, not on every build.
  late final _infos = uploadAndList(widget.storage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage')),
      body: FutureBuilder<List<FileInfo>>(
        future: _infos,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          var infos = snapshot.data;
          if (infos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              for (var info in infos)
                ListTile(
                  title: Text('${info.name} (${info.size} bytes)'),
                  subtitle: Text(info.url ?? 'no download url'),
                ),
            ],
          );
        },
      ),
    );
  }
}
