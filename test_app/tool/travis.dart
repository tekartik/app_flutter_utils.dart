import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:process_run/which.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''

flutter packages get
flutter analyze
# flutter test
flutter build web

''');

  // Check for adb and ANDROID_HOME
  if (whichSync('adb') != null &&
      Platform.environment['ANDROID_HOME'] != null) {
    await shell.run('''
      flutter build apk
''');
  } else {
    print('Android build tools not installed');
  }

  if (Platform.isMacOS) {
    if (whichSync('xcode-select') != null) {
      await shell.run('''
      flutter build ios
''');
    } else {
      print('iOS build tools not installed');
    }
  }
}
