import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';

abstract class _BaseWidget extends StatelessWidget {
  final subject = BehaviorSubject<String>();

  _BaseWidget({super.key});
}

class TestValueStream extends _BaseWidget {
  TestValueStream({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueStreamBuilder<String>(
      stream: subject,
      builder: (_, snapshot) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(snapshot.data ?? ''),
        );
      },
    );
  }
}

class TestBehaviorSubject extends _BaseWidget {
  TestBehaviorSubject({super.key});

  @override
  Widget build(BuildContext context) {
    return BehaviorSubjectBuilder<String>(
      subject: subject,
      builder: (_, snapshot) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(snapshot.data ?? ''),
        );
      },
    );
  }
}

void main() {
  Future<void> testWidget(_BaseWidget widget, WidgetTester tester) async {
    await tester.pumpWidget(widget);
    var resultFinder = find.text('');
    expect(resultFinder, findsOneWidget);
    widget.subject.add('test');
    await tester.pumpWidget(widget);
    resultFinder = find.text('');
    expect(resultFinder, findsNothing);
    resultFinder = find.text('test');
    expect(resultFinder, findsOneWidget);
  }

  testWidgets('ValueStreamBuilder', (WidgetTester tester) async {
    await testWidget(TestValueStream(), tester);
  });
  testWidgets('BehaviorSubjectBuilder', (WidgetTester tester) async {
    await testWidget(TestBehaviorSubject(), tester);
  });
}
