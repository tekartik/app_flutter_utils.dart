import 'package:tekartik_app_flutter_fs/fs.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

Directory? _dir;

Future<Directory> get dirAsync async => _dir ??= await () async {
  return await fs.getApplicationDocumentsDirectory(
    packageName: 'test1.tekartik.com',
  );
}();

File? _file;

Future<File> get fileAsync async => _file ??= await () async {
  return fs.file(fs.path.join((await dirAsync).path, 'file.txt'));
}();

void defineMenu() {
  menu('fs', () {
    //devPrint('MAIN_');
    item('app doc dir', () async {
      var dir = await fs.getApplicationDocumentsDirectory(
        packageName: 'test1.tekartik.com',
      );
      write('dir: $dir');
      await dir.list(recursive: true).listen((event) {
        write('file: ${event.path}');
      }).asFuture<void>();
    });
    item('write hello', () async {
      var file = await fileAsync;
      await file.writeAsString('hello');
      write('read: ${await file.readAsString()}');
    });
    item('write world', () async {
      var file = await fileAsync;
      await file.writeAsString('world');
      write('read: ${await file.readAsString()}');
    });
    item('delete file', () async {
      var file = await fileAsync;
      await file.delete();
      write('deleted file: $file');
      //write('delete: ${file.readAsString()}');
    });
    item('read file', () async {
      var file = await fileAsync;
      write('read: ${await file.readAsString()}');
    });
    item('delete app dir', () async {
      var dir = await dirAsync;
      await dir.delete(recursive: true);
      write('deleted dir: $dir');
      //write('delete: ${file.readAsString()}');
    });
    item('create app dir', () async {
      var dir = await dirAsync;
      await dir.create(recursive: true);
      write('created dir: $dir');
      //write('delete: ${file.readAsString()}');
    });
  });
}

void main() {
  platformInit();
  mainMenuFlutter(() {}, showConsole: true);
}
