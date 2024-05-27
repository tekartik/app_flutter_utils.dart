import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_widget/with_header_footer_list_view.dart';

// ignore: depend_on_referenced_packages

void main() {
  group('WithHeaderFooterListView', () {
    testWidgets('WithHeaderFooterListView', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: WithHeaderFooterListView.builder(
            itemBuilder: (_, __) => Container(),
            itemCount: 0,
            header: const Text('1'),
            footer: const Text('2')),
      ));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
