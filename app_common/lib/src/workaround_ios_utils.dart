import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';

/// Workaround for iOS 26 zero offset pointer event issue
/// See https://github.com/flutter/flutter/issues/177992
/// To call with if (!kIsWeb && Platform.isIOS)
void setupWorkaroundIos26() {
  if (!kIsWeb && Platform.isIOS) {
    _installZeroOffsetPointerGuard();
  }
}

// Top level global
bool _zeroOffsetPointerGuardInstalled = false;

void _installZeroOffsetPointerGuard() {
  if (_zeroOffsetPointerGuardInstalled) return;
  GestureBinding.instance.pointerRouter.addGlobalRoute(
    _absorbZeroOffsetPointerEvent,
  );
  _zeroOffsetPointerGuardInstalled = true;
}

void _absorbZeroOffsetPointerEvent(PointerEvent event) {
  if (event.position == Offset.zero) {
    GestureBinding.instance.cancelPointer(event.pointer);
  }
}
