import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_widget/delayed_display.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';
import 'package:tekartik_app_flutter_widget/view/fade_in.dart';
import 'package:tekartik_app_flutter_widget/will_pop_scope_compat.dart';

void main() {
  group('FadeIn', () {
    testWidgets('applies its curve', (tester) async {
      await tester.pumpWidget(
        const FadeIn(
          duration: Duration(milliseconds: 100),
          curve: Curves.easeIn,
          child: SizedBox(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      var opacity = tester
          .widget<FadeTransition>(find.byType(FadeTransition))
          .opacity
          .value;
      expect(opacity, closeTo(Curves.easeIn.transform(0.5), 0.01));
      await tester.pumpAndSettle();
      opacity = tester
          .widget<FadeTransition>(find.byType(FadeTransition))
          .opacity
          .value;
      expect(opacity, 1);
    });

    testWidgets('stops listening to its controller once disposed', (
      tester,
    ) async {
      var controller = FadeInController();
      await tester.pumpWidget(
        FadeIn(controller: controller, child: const SizedBox()),
      );
      controller.fadeIn();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      // Used to call forward() on the disposed animation controller.
      controller.fadeOut();
      await tester.pump();
      expect(tester.takeException(), isNull);
      controller.dispose();
    });
  });

  testWidgets('DelayedDisplay toggled then disposed within its delay', (
    tester,
  ) async {
    Widget display(bool fadeIn) => DelayedDisplay(
      delay: const Duration(milliseconds: 100),
      fadeIn: fadeIn,
      child: const SizedBox(),
    );
    await tester.pumpWidget(display(true));
    await tester.pump(const Duration(milliseconds: 50));
    // A second delay timer while the first one is pending.
    await tester.pumpWidget(display(false));
    await tester.pumpWidget(const SizedBox());
    // Used to run the first timer on the disposed animation controller.
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cv ui list item label is italic', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CvUiListItemLabel(index: 1)),
    );
    expect(
      tester.widget<Text>(find.text('item 1')).style?.fontStyle,
      FontStyle.italic,
    );
  });

  testWidgets('muiBodyWidget shrinkWrap', (tester) async {
    Future<bool> shrinkWrap(bool? value) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: muiBodyWidget(() {
              muiItem('item', () {});
            }, shrinkWrap: value),
          ),
        ),
      );
      expect(find.text('item'), findsOneWidget);
      return tester.widget<ListView>(find.byType(ListView)).shrinkWrap;
    }

    expect(await shrinkWrap(false), isFalse);
    expect(await shrinkWrap(true), isTrue);
    // The default stays a shrink wrapped list.
    expect(await shrinkWrap(null), isTrue);
  });

  group('WillPopScopeCompat', () {
    Future<void> pushPage(
      WidgetTester tester,
      GlobalKey<NavigatorState> navigatorKey,
      Widget page,
    ) async {
      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, home: const Text('home')),
      );
      navigatorKey.currentState!
          .push(MaterialPageRoute<void>(builder: (_) => page))
          .ignore();
      await tester.pumpAndSettle();
      expect(find.text('page'), findsOneWidget);
    }

    testWidgets('no onWillPop: the route pops', (tester) async {
      var navigatorKey = GlobalKey<NavigatorState>();
      await pushPage(
        tester,
        navigatorKey,
        const WillPopScopeCompat(child: Text('page')),
      );
      await navigatorKey.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('page'), findsNothing);
    });

    testWidgets('onWillPop decides', (tester) async {
      var navigatorKey = GlobalKey<NavigatorState>();
      var allow = false;
      await pushPage(
        tester,
        navigatorKey,
        WillPopScopeCompat(
          onWillPop: () async => allow,
          child: const Text('page'),
        ),
      );
      await navigatorKey.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('page'), findsOneWidget);
      allow = true;
      await navigatorKey.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('page'), findsNothing);
    });
  });
}
