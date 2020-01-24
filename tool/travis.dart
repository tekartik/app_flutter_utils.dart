import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:pub_semver/pub_semver.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''
    
  flutter doctor
    
  dartanalyzer --fatal-warnings --fatal-infos test tool
  dartfmt -n --set-exit-if-changed test tool
  pub run test

''');

  for (var dir in [
    if (Version.parse(Platform.version.split(' ').first) >=
        Version(2, 6, 0)) ...['app_fs', 'test_app'],
    'app_emit_builder',
    'app_firebase',
    'app_firebase_auth',
    'app_firebase_firestore',
    'app_plugin',
    'app_idb',
    'app_rx_utils',
    'app_prefs',
    'app_platform',
  ]) {
    shell = shell.pushd(dir);
    await shell.run('''
  
  flutter packages get
  dart tool/travis.dart
  
''');
    shell = shell.popd();
  }
}
