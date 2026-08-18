import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_list_view_test_app_lib/lazy_list_view_page.dart';
import 'package:tekartik_list_view_test_app_lib/sliver_lazy_list_page.dart';

void main() {
  testWidgets('LazyListViewDemoPage (future)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LazyListViewDemoPage(title: 'demo', itemCount: 1000),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.textContaining('/ 1000 items'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('LazyListViewDemoPage (watch)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LazyListViewDemoPage(title: 'demo', itemCount: 1000, watch: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.textContaining('/ 1000 items'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('SliverLazyListDemoPage', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SliverLazyListDemoPage()));
    await tester.pumpAndSettle();
    expect(find.text('A header sliver'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
