import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''
    
flutter doctor
  
''');

  for (var dir in [
    'app_emit_builder',
    'app_firebase',
    'app_plugin',
    'test_app',
    'app_idb',
    'app_rx_utils',
    'app_prefs',
  ]) {
    shell = shell.pushd(dir);
    await shell.run('''
  
  flutter packages get
  dart tool/travis.dart
  
''');
    shell = shell.popd();
  }
}
