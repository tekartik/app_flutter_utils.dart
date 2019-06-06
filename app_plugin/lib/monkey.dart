import 'dart:async';

import 'package:tekartik_app_flutter_plugin/src/tekartik_app_flutter_plugin.dart';

/// Android only, returns true if monkey tester is running, false otherwise
///
/// It is always false for non-Android platform.
Future<bool> get isMonkeyRunning => TekartikAppFlutterPlugin.isMonkeyRunning;
