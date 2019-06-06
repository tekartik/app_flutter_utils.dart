import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  var packageName = 'com.tekartik.tekartik_app_flutter_test_app';
  await shell.run('''

# adb shell monkey -p $packageName -v --pct-touch 98 --pct-majornav 1 --pct-motion 1 5000 
adb shell monkey -p $packageName -v --pct-majornav 100 --throttle 1 5000
''');
}
