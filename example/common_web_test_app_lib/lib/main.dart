import 'package:tekartik_app_flutter_common_web_utils/cursor_utils.dart';
import 'package:tekartik_test_menu_flutter/test.dart';

void defineMenu() {
  menu('common_web', () {
    menu('cursor', () {
      item('hide cursor', () {
        write('hiding cursor');
        hideCursor();
      });
      item('show cursor', () {
        write('showing cursor');
        showCursor();
      });
    });
  });
}
