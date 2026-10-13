import 'package:cv/cv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';

class _Sub extends CvModelBase {
  final name = CvField<String>('name');
  @override
  CvFields get fields => [name];
}

class _Model extends CvModelBase {
  final modelMap = CvModelMapField<_Sub>('modelMap');
  @override
  CvFields get fields => [modelMap];
}

void main() {
  testWidgets('muiGetString chained right after the previous one', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (builderContext) {
            context = builderContext;
            return const SizedBox();
          },
        ),
      ),
    );
    String? first;
    Future<String?>? second;
    // Ask again as soon as the first answer is known, while the first dialog
    // is still animating out.
    // ignore: unawaited_futures
    muiGetString(context, value: 'a').then((value) {
      first = value;
      second = muiGetString(context, value: 'b');
    });
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'hello');
    await tester.tap(find.text('OK'));
    Object? error;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      error ??= tester.takeException();
    }
    expect(error, isNull);
    expect(first, 'hello');
    expect(second, isNotNull);
    await tester.pumpAndSettle();
    expect(find.text('b'), findsOneWidget);
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(await second, isNull);
  });

  testWidgets('cv_ui model map add button adds a model under a new key', (
    tester,
  ) async {
    cvAddConstructors([_Model.new, _Sub.new]);
    var model = _Model()..modelMap.v = {'k': _Sub()..name.v = 'x'};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CvUiModelEdit(
              controller: CvUiModelEditController(model: model),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'k2');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(model.modelMap.v!.keys, ['k', 'k2']);
    expect(model.modelMap.v!['k2'], isA<_Sub>());
  });
}
