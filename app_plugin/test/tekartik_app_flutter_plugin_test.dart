import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_plugin/monkey.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('tekartik_app_flutter_plugin');

  /// Supports for access being non-nullable in Dart 3.
  T? makeNullable<T>(T? value) => value;

  setUp(() {
    makeNullable(TestDefaultBinaryMessengerBinding.instance)!
        .defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return true;
        });
  });

  tearDown(() {
    makeNullable(
      TestDefaultBinaryMessengerBinding.instance,
    )!.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    // Always false when not on Android
    expect(await isMonkeyRunning, isFalse);
  });
}
