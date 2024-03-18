@Deprecated('include hide_cursor.dart instead')
library;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show window;

import 'package:tekartik_common_utils/async_utils.dart';

var _useFixLoop = true;
var _debugCursor = false; // devWarning(true);
Future<void> hideCursor() async {
  await _flutterCursorWeb.hide();
}

Future<void> showCursor() async {
  await _flutterCursorWeb.show();
}

class FlutterCursorWeb {
  FlutterCursorWeb() {
    if (_useFixLoop) {
      _fix();
    }
  }
  Future<void> _fix() async {
    while (true) {
      var element = window.document.querySelector('flutter-view');

      if (element != null) {
        //  Wait for cursor to appear
        var style = element.attributes['style'];

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
          element.attributes['style'] =
              style!.replaceAll(previousCursorStyle, cursorStyle);
        } else {
          element.attributes['style'] =
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

final _flutterCursorWeb = FlutterCursorWeb();
