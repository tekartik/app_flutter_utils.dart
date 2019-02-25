import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''
    
flutter doctor
  
''');

  /*
  for (var dir in [
    'app',
    'app_emit',
    'app_pager',
    'app_serialize',
    'app_mirrors'
  ]) {
    shell = shell.pushd(dir);
    await shell.run('''
    
  pub get
  dart tool/travis.dart
  
''');
    shell = shell.popd();
  }
  */
}
