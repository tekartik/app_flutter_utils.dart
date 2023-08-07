import 'package:flutter/foundation.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_app_plugin_test_app_lib/main.dart' as app_plugin;
import 'package:tekartik_common_test_app_lib/main.dart' as common;
import 'package:tekartik_fs_test_app_lib/main.dart' as fs;
import 'package:tekartik_idb_test_app_lib/main.dart' as idb;
import 'package:tekartik_prefs_test_app_lib/main.dart' as prefs;
import 'package:tekartik_sembast_test_app_lib/main.dart' as sembast;
import 'package:tekartik_sqflite_test_app_lib/main.dart' as sqflite;
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';
import 'package:tekartik_widget_test_app_lib/main.dart' as widget;

void main() {
  platformInit();
  if (!kIsWeb) {
    sqfliteWindowsFfiInit();
  }
  mainMenu(() {
    prefs.defineMenu();
    idb.defineMenu();
    fs.defineMenu();
    sembast.defineMenu();
    sqflite.defineMenu();
    widget.defineMenu();
    app_plugin.defineMenu();
    common.defineMenu();
  }, showConsole: true);
}
