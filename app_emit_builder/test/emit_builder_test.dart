import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_emit/emit.dart';
import 'package:tekartik_app_emit_builder/emit_builder.dart';

void main() {
  group('EmitFutureOrBuilder', () {
    testWidgets('doc', (WidgetTester tester) async {
      var controller = EmitFutureOrController<String>();
      Widget getMaterialApp() {
        return MaterialApp(
          // ignore: deprecated_member_use_from_same_package, deprecated_member_use
          home: EmitFutureOrBuilder<String>(
            futureOr: controller.futureOr,
            builder: (context, snapshot) => Text(snapshot.data ?? 'no data'),
          ),
        );
      }

      await tester.pumpWidget(getMaterialApp());
      expect(find.text('no data'), findsOneWidget);
      expect(find.text('done'), findsNothing);
      controller.complete('done');
      await tester.pump();
      expect(find.text('done'), findsOneWidget);
    });
  });
}
