import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';

class TestBloc extends BaseBloc {
  final String value = 'test_result';
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        blocBuilder: () => TestBloc(),
        child: Scaffold(
          body: ListView(
            children: [
              Builder(
                builder: (context) {
                  return Text(BlocProvider.of<TestBloc>(context).value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Provider', (WidgetTester tester) async {
    await tester.pumpWidget(const TestApp());
    final resultFinder = find.text('test_result');
    expect(resultFinder, findsOneWidget);
  });
}
