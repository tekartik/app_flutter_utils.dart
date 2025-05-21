library;

// ignore: avoid_web_libraries_in_flutter

import 'package:tekartik_app_common_utils/common_utils_import.dart';
import 'package:web/web.dart' as web;

var _useFixLoop = true;
var _debugCursor = false;

/// Hide the cursor
Future<void> hideCursor() async {
  await _flutterCursorWeb.hide();
}

/// Show the cursor
Future<void> showCursor() async {
  await _flutterCursorWeb.show();
}

class _FlutterCursorWeb {
  _FlutterCursorWeb() {
    if (_useFixLoop) {
      _fix();
    }
  }
  Future<void> _fix() async {
    while (true) {
      var element = web.window.document.querySelector('flutter-view');

      if (element != null) {
        var styleAttribute = (element.attributes.getNamedItem('style'));
        //  Wait for cursor to appear
        var style = styleAttribute?.value;

        // devPrint('$_shouldShow style: $style');
        var cursorDefault = 'cursor: default;';
        var cursorNone = 'cursor: none;';
        var cursorStyle = _shouldShow ? cursorDefault : cursorNone;
        var previousCursorStyle = _shouldShow ? cursorNone : cursorDefault;
        if (_debugCursor) {
          // ignore: avoid_print
          print('[cursor] (show: $_shouldShow) style: $style');
        }
        if (style?.contains(cursorStyle) ?? false) {
          if (!_useFixLoop) {
            break;
          } else {
            await sleep(1000);
            continue;
          }
        }
        if (style?.contains(previousCursorStyle) ?? false) {
          styleAttribute?.value = style!.replaceAll(
            previousCursorStyle,
            cursorStyle,
          );
        } else {
          styleAttribute?.value =
              '$cursorStyle${style == null ? '' : ' $style'}';
        }
      }

      await sleep(1000);
    }
  }

  var _shouldShow = true;

  Future<void> _show(bool show) async {
    if (_debugCursor) {
      // ignore: avoid_print
      print('[cursor] show: $show');
    }
    _shouldShow = show;
    if (!_useFixLoop) {
      await _fix();
    }
  }

  Future<void> show() async {
    await _show(true);
  }

  Future<void> hide() async {
    await _show(false);
  }
}

final _flutterCursorWeb = _FlutterCursorWeb();
