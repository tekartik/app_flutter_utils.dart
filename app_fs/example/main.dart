// Counts the launches of the app in a file of its documents directory, on
// every platform (IndexedDB on the web).
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_fs/fs.dart';

/// Reads, increments and writes the launch count in [fileSystem].
Future<int> countLaunch(FileSystem fileSystem) async {
  var dir = await fileSystem.getApplicationDocumentsDirectory(
    packageName: 'com.tekartik.app_fs_example',
  );
  await dir.create(recursive: true);
  var file = fileSystem.file(fileSystem.path.join(dir.path, 'launches.txt'));
  var count = 0;
  if (await file.exists()) {
    count = int.tryParse(await file.readAsString()) ?? 0;
  }
  count++;
  await file.writeAsString('$count');
  return count;
}

Future<void> main() async {
  // path_provider needs the binding.
  WidgetsFlutterBinding.ensureInitialized();
  var count = await countLaunch(fs);
  runApp(
    Center(
      child: Text(
        'Launch #$count',
        textDirection: TextDirection.ltr,
        style: const TextStyle(fontSize: 24),
      ),
    ),
  );
}
