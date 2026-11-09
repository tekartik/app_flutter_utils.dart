// Path urls on the web and a tap that hides or shows the mouse cursor; both
// are no-ops on mobile and desktop.
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_common_web_utils/cursor_utils.dart';
import 'package:tekartik_app_flutter_common_web_utils/url_strategy.dart';

void main() {
  // Once, before runApp. `?url-strategy=hash` in the page url overrides it.
  webUsePathUrlStrategy();
  runApp(const ExampleApp());
}

/// Toggles the cursor on a tap.
class ExampleApp extends StatefulWidget {
  /// Toggles the cursor on a tap.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  var _hidden = false;

  Future<void> _toggle() async {
    setState(() => _hidden = !_hidden);
    if (_hidden) {
      await hideCursor();
    } else {
      await showCursor();
    }
  }

  @override
  Widget build(BuildContext context) {
    var strategy = webIsPathUrlStrategy
        ? 'path'
        : (webIsHashUrlStrategy ? 'hash' : 'none (not the web)');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: ColoredBox(
          color: const Color(0xFFFFFFFF),
          child: Center(
            child: Text(
              'url strategy: $strategy\n'
              'cursor ${_hidden ? 'hidden' : 'shown'} (tap to toggle)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF000000), fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
