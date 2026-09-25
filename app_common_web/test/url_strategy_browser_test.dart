@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_common_web_utils/url_strategy.dart';

Future<void> main() async {
  test('webUseHashUrlStrategy', () {
    // The test page has no url-strategy parameter and no base href (needed by
    // the path strategy), the url strategy can only be set once.
    webUseHashUrlStrategy();
    expect(webIsHashUrlStrategy, isTrue);
    expect(webIsPathUrlStrategy, isFalse);
  });
}
