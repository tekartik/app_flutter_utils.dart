import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_plugin/monkey.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('tekartik_app_flutter_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return true;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // Always false when not on Android
    expect(await isMonkeyRunning, isFalse);
  });
}
