import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';

void main() {
  testWidgets('MuiScreenWidget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: muiScreenWidget('title', () {
          muiItem('item', () {});
        }),
      ),
    );

    expect(find.text('title'), findsOneWidget);
    expect(find.text('item'), findsOneWidget);
  }, skip: true); // TODO investigate

  test('test', () {
    muiMenu('menu', () {
      muiItem('item', () {});
    });
  });
}
