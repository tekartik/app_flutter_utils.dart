import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''
# Analyze
flutter analyze
dartfmt -n --set-exit-if-changed .

# Test
flutter test
''');
}
