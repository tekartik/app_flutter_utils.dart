import 'dart:convert';
import 'dart:io';

import 'package:process_run/shell_run.dart';
import 'package:process_run/which.dart';
import 'package:pub_semver/pub_semver.dart';

Future<Version> getFlutterVersion() async {
  var flutterVersion = Version.parse(LineSplitter.split(
          (await run('flutter --version')).first.stdout.toString())
      .first
      .split(' ')[1]);
  return flutterVersion;
}

Future main() async {
  var shell = Shell();

  var flutterVersion = await getFlutterVersion();
  var webMinFlutterVersion = Version(1, 14, 6);

  if (flutterVersion >= webMinFlutterVersion) {
    await shell.run('flutter config --enable-web');
  }
  await shell.run('''
flutter packages get
flutter analyze
''');

  if (flutterVersion >= webMinFlutterVersion) {
    await shell.run('flutter build web');
  }

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
