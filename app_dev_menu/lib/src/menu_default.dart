import 'package:tekartik_app_dev_menu/dev_menu.dart' as dev_menu;
export 'package:tekartik_app_dev_menu/dev_menu.dart'
    hide mainMenu, mainMenuUniversal;

/// Universal main menu - io or web implementation
void mainMenuUniversal(
  List<String> arguments,
  void Function() body, {
  bool? noConsole,
}) {
  dev_menu.mainMenuUniversal(arguments, body);
}

/// Shortcut
const mainMenu = mainMenuUniversal;
