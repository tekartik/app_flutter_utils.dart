import 'package:tekartik_test_menu_flutter/test.dart';

import 'fs_main.dart' as fs;
import 'monkey_main.dart' as monkey;

void main() {
  // print('Starting test app');
  mainMenuFlutter(() {
    fs.main();
    monkey.main();
  });
}
