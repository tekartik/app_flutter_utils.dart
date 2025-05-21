import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tekartik_common_utils/env_utils.dart';

class TekartikAppFlutterPlugin {
  static const MethodChannel _channel = MethodChannel(
    'tekartik_app_flutter_plugin',
  );

  static Future<String?> get platformVersion async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Android only, returns false otherwise
  static Future<bool> get isMonkeyRunning async {
    if (Platform.isAndroid) {
      try {
        final running = await callIsMonkeyRunning ?? false;
        return running;
      } catch (e) {
        if (isDebug) {
          print('error $e'); // ignore: avoid_print
        }
      }
    }

    return false;
  }

  static Future<bool?> get callIsMonkeyRunning async =>
      await _channel.invokeMethod('isMonkeyRunning') as bool?;
}
