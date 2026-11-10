@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_full_screen/full_screen.dart';

/// Runs [script] in the page.
void _eval(String script) {
  globalContext.callMethod('eval'.toJS, script.toJS);
}

/// Pretend the document is full screen (or not), as the browser does after a
/// user gesture (or escape): no gesture is possible in a test.
void _setDocumentFullScreen(bool fullScreen) {
  _eval('''
Object.defineProperty(document, 'fullscreenElement', {
  configurable: true,
  get: () => ${fullScreen ? 'document.documentElement' : 'null'}
});
''');
}

/// Back to the browser's own `document.fullscreenElement`.
void _restoreDocumentFullScreen() {
  _eval('delete document.fullscreenElement;');
}

void _fireFullScreenChange() {
  _eval("document.dispatchEvent(new Event('fullscreenchange'));");
}

void main() {
  group('full_screen_web', () {
    test('create', () async {
      var fullScreen = createPlatformFullScreen();
      expect(fullScreen.supported, isA<bool>());
      expect(fullScreen.isFullScreen, isFalse);
      // Refused without a user gesture (or granted on a permissive test
      // browser): no error either way.
      await fullScreen.setFullScreen(true);
      await fullScreen.setFullScreen(false);
      expect(fullScreen.isFullScreen, isFalse);
      fullScreen.dispose();
    });

    test(
      'created while the document is full screen, escape reported',
      () async {
        // Another screen left the document full screen.
        _setDocumentFullScreen(true);
        try {
          var fullScreen = createPlatformFullScreen();
          var changes = <bool>[];
          fullScreen.onChanged.listen(changes.add);
          expect(fullScreen.isFullScreen, isTrue);

          // Escape.
          _setDocumentFullScreen(false);
          _fireFullScreenChange();
          await pumpEventQueue();
          expect(fullScreen.isFullScreen, isFalse);
          expect(changes, [false]);
          fullScreen.dispose();
        } finally {
          _restoreDocumentFullScreen();
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}
