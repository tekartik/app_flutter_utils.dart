import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:tekartik_build_utils/flutter/app/generate.dart';

// dir name
String dirName = join('..', 'example', 'test_app');

/// pub package name
String appName = 'tekartik_app_utils_test_app';

Future main() async {
  await generate();
}

Future generate({bool? force}) async {
  await run('dart --version');
  await run('flutter --version');
  await gitGenerate(dirName: dirName, appName: appName, force: force);
}
