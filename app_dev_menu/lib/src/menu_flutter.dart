import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart'
    show mainMenuFlutter, initTestMenuFlutter;

export 'package:tekartik_app_dev_menu/dev_menu.dart'
    hide mainMenu, mainMenuUniversal;
export 'package:tekartik_test_menu_flutter/test_menu_flutter.dart'
    show navigator, buildContext, initTestMenuFlutter, mainMenuFlutter;

/// Shortcut, to prefer over initTestMenuFlutter
const initMainMenuFlutter = initTestMenuFlutter;

/// Universal main menu - flutter implementation
void mainMenuUniversal(
  List<String> arguments,
  void Function() body, {
  bool? noConsole,
}) {
  noConsole ??= false;
  mainMenuFlutter(body, showConsole: !noConsole);
}

/// Shortcut
const mainMenu = mainMenuUniversal;
