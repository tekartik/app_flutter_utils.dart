import 'package:process_run/shell.dart';
import 'package:tekartik_build_utils/common_import.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''
    
  flutter doctor
    
  dartanalyzer --fatal-warnings --fatal-infos test tool
  dartfmt -n --set-exit-if-changed test tool
  pub run test

''');

  for (var dir in [
    'app_bloc',
    'app_fs',
    'test_app',
    'app_emit_builder',
    'app_firebase',
    'app_firebase_auth',
    'app_firebase_firestore',
    'app_plugin',
    'app_idb',
    'app_rx_utils',
    'app_prefs',
    'app_platform',
    'app_roboto',
    'app_sembast',
    join('example', 'test_app')
  ]) {
    shell = shell.pushd(dir);
    print('project: $dir');
    await shell.run('''
  
  flutter packages get
  dart tool/travis.dart
  
''');
    shell = shell.popd();
  }
}
