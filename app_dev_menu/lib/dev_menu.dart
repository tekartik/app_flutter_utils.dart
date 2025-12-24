export 'package:tekartik_app_dev_menu/dev_menu.dart'
    hide mainMenu, mainMenuUniversal;

export 'src/menu_default.dart' if (dart.library.ui) 'src/menu_flutter.dart';
