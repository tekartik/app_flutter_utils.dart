import 'package:tekartik_app_flutter_plugin/monkey.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

void defineMenu() {
  if (platformContext.io?.isAndroid ?? false) {
    menu('app_plugin', () {
      item('isMonkey running', () async {
        write(await isMonkeyRunning);
      });
    });
  }
}

void main() {
  platformInit();
  mainMenuFlutter(() {}, showConsole: true);
}
