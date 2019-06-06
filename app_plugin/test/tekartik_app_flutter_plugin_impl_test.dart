import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_plugin/src/tekartik_app_flutter_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('tekartik_app_flutter_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'isMonkeyRunning') {
        return true;
      }
      return null;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await TekartikAppFlutterPlugin.callIsMonkeyRunning, isTrue);
  });
}
