@TestOn('vm')
import 'dart:io';
import 'package:path/path.dart';
import 'package:tekartik_build_utils/cmd_run.dart';
import 'package:test/test.dart';
import 'package:process_run/shell_run.dart';
import 'package:tekartik_build_utils/flutter/app/generate.dart';
import 'package:tekartik_build_utils/flutter/flutter.dart';
import 'package:fs_shim/utils/io/copy.dart';

var topDir = '..';
void main() {
  group(
    'min_app',
    () {
      test('fs_generate', () async {
        for (var dir in [
          'fs_test_app_lib',
          'idb_test_app_lib',
          'prefs_test_app_lib',
          'sembast_test_app_lib',
          'sqflite_test_app_lib',
          'widget_test_app_lib'
        ]) {
          await copyDirectory(Directory(join(topDir, 'example', '$dir')),
              Directory(join(topDir, '.dart_tool', dir)));
        }
        var dirName = join(topDir, '.dart_tool', 'test_app');
        var src = join(topDir, 'example', 'test_app');
        await fsGenerate(dir: dirName, src: src);
        var context = await flutterContext;
        if (context.supportsWeb) {
          await Shell(workingDirectory: dirName).run('''
              flutter build web
              ''');
        }
      });
    },
    skip: !isFlutterSupported,
    // Allow 10 mn for web build (sdk download)
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
