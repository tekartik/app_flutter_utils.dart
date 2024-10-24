import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_common_web_utils/src/url_strategy/platform/url_strategy.dart';

Future<void> main() async {
  group('url_strategy', () {
    test('setPathUrlStrategy', () async {
      setPathUrlStrategy();
    });

    test('setHashUrlStrategy', () async {
      setHashUrlStrategy();
    });
  });
}
