// ignore_for_file: depend_on_referenced_packages

import 'package:process_run/shell.dart';
import 'package:tekartik_app_dev_menu_flutter/dev_menu.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/env_utils.dart';

void main(List<String> args) {
  platformInit();
  mainMenu(args, () {
    menu('platform', () {
      item('context', () {
        write(jsonPretty(platformContext.toMap())); // ignore: avoid_print
      });
      item('shell', () {
        if (!kDartIsWeb) {
          write('shell available');
          var env = ShellEnvironment();
          write('env:');
          write(jsonPretty(Map.of(env)));
          write('aliases:');
          write(jsonPretty(Map.of(env.aliases)));
          write('vars:');
          write(jsonPretty(Map.of(env.vars)));
          write('paths:');
          write(jsonPretty(List.of(env.paths)));
        } else {
          write('shell not available on web');
        }
      });
    });
  });
}
