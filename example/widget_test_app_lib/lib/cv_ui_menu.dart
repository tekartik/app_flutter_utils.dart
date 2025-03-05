import 'package:cv/cv.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_utils/common_utils_import.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';
import 'package:tekartik_test_menu_flutter/test.dart';

enum CvUiStringEditResultType { cancel, ok, deleted }

class _MyModel extends CvModelBase {
  final name = CvField<String>('name');
  final description = CvField<String>('description');
  final age = CvField<int>('age');
  final sub = CvModelField<_MySubModel>('sub');
  @override
  CvFields get fields => [name, description, age, sub];
}

class _MySubModel extends CvModelBase {
  final subname = CvField<String>('subname');

  @override
  CvFields get fields => [subname];
}

class CvUiStringEditResult {
  final CvUiStringEditResultType type;
  final String? text;

  CvUiStringEditResult({required this.type, this.text});
}

void menuCvUi() {
  menu('Cv ui', () {
    item('CvUiValue', () async {
      cvAddConstructors([_MyModel.new, _MySubModel.new]);
      var result = await Navigator.of(castAsNullable(buildContext)!)
          .push(MaterialPageRoute<Object?>(builder: (_) {
        return Scaffold(
            appBar: AppBar(title: const Text('Cv UI Value')),
            body: ListView(children: [
              const CvUiTextValue(text: 'Hello'),
              CvUiStringFieldValue(
                field: CvField<String>('someOtherKey', 'someValue'),
              ),
              CvUiStringFieldValue(field: CvField<String>('someKey')),
              CvUiModelValue(model: _MyModel()..fillModel(cvFillOptions1)),
              const Text('only 1 field'),
              CvUiModelValue(model: _MyModel()..name.v = 'My name'),
            ]));
      }));
      if (muiBuildContext.mounted) {
        await muiSnack(muiBuildContext, 'result: $result');
      }
    });
  });
}
