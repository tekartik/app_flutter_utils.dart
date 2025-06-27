import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// To support swipe on desktop
/// return MaterialApp(
//       scrollBehavior: AppScrollBehavior(),
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
