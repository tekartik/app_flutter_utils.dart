import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell_run.dart';
import 'package:process_run/which.dart';

/*Future<String> _flutterVersion = () async {
  return await getFlutterBinVersion();
}();*/
Future<String> _flutterChannel = () async {
  return await getFlutterBinChannel();
}();

Future<bool> supportsFlutterWeb = () async {
  var channel = await _flutterChannel;
  return [dartChannelBeta, dartChannelDev, dartChannelMaster].contains(channel);
}();

Future main() async {
  var shell = Shell();

  if (await supportsFlutterWeb) {
    await shell.run('flutter config --enable-web');
  }
  await shell.run('''
flutter create .
flutter packages get
flutter analyze
''');

  if (await supportsFlutterWeb) {
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
