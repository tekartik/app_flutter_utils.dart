import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_plugin/src/tekartik_app_flutter_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('tekartik_app_flutter_plugin');

  /// Supports for access being non-nullable in Dart 3.
  T? makeNullable<T>(T? value) => value;

  setUp(() {
    makeNullable(TestDefaultBinaryMessengerBinding.instance)!
        .defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'isMonkeyRunning') {
            return true;
          }
          return null;
        });
  });

  tearDown(() {
    makeNullable(
      TestDefaultBinaryMessengerBinding.instance,
    )!.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await TekartikAppFlutterPlugin.callIsMonkeyRunning, isTrue);
  });
}
