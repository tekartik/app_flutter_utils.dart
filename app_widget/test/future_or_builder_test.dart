import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_widget/app_widget.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';

String no(String value) => 'no_$value';

var value = 'value';
var noValue = no(value);

void main() {
  Future<void> setupValue(WidgetTester tester, FutureOr<String> value) async {
    await tester.pumpWidget(
      FutureOrBuilder<String>(
        futureOr: value,
        builder: (context, snapshot) =>
            Text(snapshot.data ?? noValue, textDirection: TextDirection.ltr),
      ),
    );
  }

  group('FutureOrBuilder', () {
    testWidgets('doc', (WidgetTester tester) async {
      Widget getMaterialApp() {
        var ready = false;

        Future<String> getReady() async {
          // Getting ready
          // ... doStuff
          ready = true;
          return 'done';
        }

        FutureOr<String> loadData() {
          // ... do Stuff
          if (!ready) {
            return getReady();
          }
          return 'done';
        }

        return MaterialApp(
          home: FutureOrBuilder<String>(
            futureOr: loadData(),
            builder: (context, snapshot) => Text(snapshot.data ?? 'no data'),
          ),
        );
      }

      await tester.pumpWidget(getMaterialApp());
      expect(find.text('no data'), findsOneWidget);
      expect(find.text('done'), findsNothing);
      await tester.pump();
      expect(find.text('done'), findsOneWidget);
    });
    testWidgets('immediate 1', (WidgetTester tester) async {
      await setupValue(tester, value);
      expect(find.text(value), findsOneWidget);
      expect(find.text(noValue), findsNothing);
    });

    testWidgets('immediate 2', (WidgetTester tester) async {
      await setupValue(tester, SynchronousFuture(value));
      expect(find.text(value), findsOneWidget);
      expect(find.text(noValue), findsNothing);
    });

    testWidgets('future 1', (WidgetTester tester) async {
      await setupValue(tester, Future.value(value));
      expect(find.text(noValue), findsOneWidget);
      expect(find.text(value), findsNothing);
      await tester.pump();
      expect(find.text(value), findsOneWidget);
      expect(find.text(noValue), findsNothing);
    });

    testWidgets('future 2', (WidgetTester tester) async {
      await setupValue(
        tester,
        Future.sync(() {
          return value;
        }),
      );
      expect(find.text(noValue), findsOneWidget);
      expect(find.text(value), findsNothing);
      await tester.pump();
      expect(find.text(value), findsOneWidget);
      expect(find.text(noValue), findsNothing);
    });

    testWidgets('future 3', (WidgetTester tester) async {
      await setupValue(
        tester,
        Future.sync(() async {
          return value;
        }),
      );
      expect(find.text(noValue), findsOneWidget);
      expect(find.text(value), findsNothing);
      await tester.pump();
      expect(find.text(value), findsOneWidget);
      expect(find.text(noValue), findsNothing);
    });

    testWidgets('delayed 500', (WidgetTester tester) async {
      await setupValue(
        tester,
        Future.sync(() async {
          await sleep(500);
          return value;
        }),
      );
      expect(find.text(noValue), findsOneWidget);
      expect(find.text(value), findsNothing);
      await tester.pump();
      // Not yet
      expect(find.text(noValue), findsOneWidget);
      expect(find.text(value), findsNothing);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text(value), findsOneWidget);
      expect(find.text(noValue), findsNothing);
      return;
    });
  });
}
