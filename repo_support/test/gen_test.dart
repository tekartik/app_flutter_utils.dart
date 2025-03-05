@TestOn('vm')
library;

import 'dart:io';

import 'package:fs_shim/utils/io/copy.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:tekartik_build_utils/flutter/flutter.dart';
import 'package:tekartik_prj_tktools/dtk/dtk_prj.dart';
import 'package:test/test.dart';

var topDir = '..';
void main() {
  group(
    'min_app',
    () {
      test('fs_generate', () async {
        var dstDir = join(topDir, '.dart_tool', 'tekartik', 'gen');
        for (var dir in [
          'fs_test_app_lib',
          'idb_test_app_lib',
          'prefs_test_app_lib',
          'sembast_test_app_lib',
          'sqflite_test_app_lib',
          'widget_test_app_lib',
          'common_test_app_lib',
          'common_web_test_app_lib',
          'app_plugin_test_app_lib',
          'navigator_test_app_lib',
          'image_test_app_lib',
          'test_app',
        ]) {
          await copyDirectory(Directory(join(topDir, 'example', dir)),
              Directory(join(dstDir, dir)));
        }
        var dirName = join(dstDir, 'test_app');
        //var src = join(topDir, 'example', 'test_app');

        var prj = DtkProject(dstDir);
        await prj.createWorkspaceRootProject();
        await prj.addAllProjectsToWorkspace(
            keepExistingWorkspaceResolution: true);
        //await fsGenerate(dir: dirName, src: src);
        var context = await flutterContext;
        if (context.supportsWeb!) {
          await Shell(workingDirectory: dirName).run('''
              flutter build web
              ''');
        }
      });
    },
    skip: true, //!isFlutterSupported,
    // Allow 10 mn for web build (sdk download)
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
