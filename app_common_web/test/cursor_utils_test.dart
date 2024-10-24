import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_common_web_utils/cursor_utils.dart';

Future<void> main() async {
  group('cursor_utils', () {
    test('hideCursor', () async {
      await hideCursor();
    });

    test('showCursor', () async {
      await showCursor();
    });
  });
}
