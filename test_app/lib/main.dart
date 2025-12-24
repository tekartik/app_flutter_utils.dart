import 'package:tekartik_app_dev_menu_flutter/dev_menu.dart';

import 'fs_main.dart' as fs;
import 'monkey_main.dart' as monkey;

Future<void> main(List<String> args) async {
  // print('Starting test app');
  mainMenuUniversal(args, () {
    fs.main();
    monkey.main();
  });
}
