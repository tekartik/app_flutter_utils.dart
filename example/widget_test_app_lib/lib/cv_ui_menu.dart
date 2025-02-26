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

    item('showMuiMenu', () async {
      var result = await showMuiMenu<Object?>(
          castAsNullable(buildContext)!, 'simple', () {
        muiItem('Pop', () => Navigator.of(muiBuildContext).pop(null));
        muiItem('Pop Some text',
            () => Navigator.of(muiBuildContext).pop('Some text'));
        muiItem('Snack Some text', () {
          muiSnack(muiBuildContext, 'Some text');
        });
      });
      write('result: $result');
    });

    item('subMenu', () async {
      var result = await showMuiMenu<Object?>(
          castAsNullable(buildContext)!, 'simple', () {
        muiItem('Pop', () => Navigator.of(muiBuildContext).pop(null));

        muiMenu('sub', () {
          muiItem('Pop Sub', () => Navigator.of(muiBuildContext).pop(null));
          muiItem('Pop Sub Some text',
              () => Navigator.of(muiBuildContext).pop('Sub Some text'));

          muiItem('showMuiMenu', () async {
            var result = await showMuiMenu<Object?>(
                castAsNullable(buildContext)!, 'simple', () {
              muiItem('Pop', () => Navigator.of(muiBuildContext).pop(null));
              muiItem('Pop Some text',
                  () => Navigator.of(muiBuildContext).pop('Some text'));
            });
            write('result: $result');
          });
        });
        muiItem('Pop Some text',
            () => Navigator.of(muiBuildContext).pop('Some text'));
      });
      write('result: $result');
    });
    item('muiConfirm', () async {
      var result = await muiConfirm(buildContext!);
      write('result: $result');
    });
    String? value;
    item('getString', () async {
      var result = await muiGetString(buildContext!, value: value);
      value = result;
      write('result: $result');
    });
    item('selectString', () async {
      var result = await muiSelectString(buildContext!, list: ['Some items']);
      //value = result;
      write('result: $result');
    });
  });
}
