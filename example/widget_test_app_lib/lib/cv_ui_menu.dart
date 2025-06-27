import 'package:cv/cv.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_utils/common_utils_import.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';
import 'package:tekartik_test_menu_flutter/test.dart';

enum CvUiStringEditResultType { cancel, ok, deleted }

class _Dummy {}

class _MyModel extends CvModelBase {
  final name = CvField<String>('name');
  final description = CvField<String>('description');
  final age = CvField<int>('age');
  final ratio = CvField<num>('ratio');
  final enabled = CvField<bool>('enabled');
  final mapModel = CvModelField<CvMapModel>('mapModel');
  final sub = CvModelField<_MySubModel>('sub');
  final stringList = CvListField<String>('stringList');
  final intList = CvListField<int>('intList');
  final subList = CvModelListField<_MySubModel>('subList');
  final modelMap = CvModelMapField<_MySubModel>('modelMap');
  final dummy = CvField<_Dummy>('dummy');
  @override
  CvFields get fields => [
    name,
    description,
    age,
    ratio,
    enabled,
    sub,
    mapModel,
    intList,
    stringList,
    subList,
    mapModel,
    dummy,
  ];
}

class _MySubModel extends CvModelBase {
  final subname = CvField<String>('subname');
  final other = CvField<String>('other');
  final subSubList = CvModelListField<_MySubSubModel>('subSubList');
  @override
  CvFields get fields => [subname, other, subSubList];
}

class _MySubSubModel extends CvModelBase {
  final subSubName = CvField<String>('subSubName');
  final subSubOther = CvField<bool>('subSubOther');
  final modelMap = CvModelMapField<_MySubModel>('subModelMap');
  @override
  CvFields get fields => [subSubName, subSubOther, modelMap];
}

class CvUiStringEditResult {
  final CvUiStringEditResultType type;
  final String? text;

  CvUiStringEditResult({required this.type, this.text});
}

BuildContext get _buildContext => castAsNullable(buildContext)!;
Future<Object?> _push({required WidgetBuilder builder}) async {
  return await Navigator.of(
    _buildContext,
  ).push<Object?>(MaterialPageRoute<Object?>(builder: builder));
}

void menuCvUi() {
  menu('Cv ui', () {
    debugCvUi = true;
    enter(() {
      cvAddConstructors([_MyModel.new, _MySubModel.new, _MySubSubModel.new]);
    });
    item('CvUiValue', () async {
      //cvAddConstructors([_MyModel.new, _MySubModel.new, _MySubSubModel.new]);
      var result = await _push(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cv UI Value')),
            body: ListView(
              children: [
                const CvUiTextValue(text: 'Hello'),
                CvUiStringFieldValue(
                  field: CvField<String>('someOtherKey', 'someValue'),
                ),
                CvUiStringFieldValue(field: CvField<String>('someKey')),
                CvUiModelValue(
                  model: _MyModel()
                    ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 3))
                    ..dummy.v = _Dummy(),
                ),
                const Text('only 1 field'),
                CvUiModelValue(model: _MyModel()..name.v = 'My name'),
                const CvUiTextValue(text: 'Hello'),
                const CvUiListValue(list: [1, 2, 3, 4]),
              ],
            ),
          );
        },
      );
      if (muiBuildContext.mounted) {
        await muiSnack(muiBuildContext, 'result: $result');
      }
    });
    item('CvUiModelView', () async {
      var result = await _push(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cv UI ModelView')),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CvUiModelView(
                    model: _MyModel()
                      ..fillModel(
                        CvFillOptions(valueStart: 0, collectionSize: 3),
                      )
                      ..dummy.v = _Dummy(),
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (_buildContext.mounted) {
        await muiSnack(_buildContext, 'result: $result');
      }
    });

    Future<void> edit(CvModel model) async {
      var result = await _push(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cv UI ModelEdit')),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CvUiModelEdit(
                    controller: CvUiModelEditController(model: model),
                  ),
                ),
              ],
            ),
          );
        },
      );
      if (_buildContext.mounted) {
        await muiSnack(_buildContext, 'result: $result');
      }
    }

    _MyModel? lastModel;
    item('CvUiModelEdit last', () async {
      var model = lastModel ??= (_MyModel()
        ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 3))
        ..dummy.v = _Dummy());
      await edit(model);
    });

    item('CvUiModelEdit all', () async {
      var model = lastModel = _MyModel()
        ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 3))
        ..dummy.v = _Dummy();
      await edit(model);
    });

    item('CvUiModelEdit intList', () async {
      var model = lastModel = (_MyModel()
        ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 3))
        ..dummy.v = _Dummy());
      model = _MyModel()..intList.v = model.intList.v;
      await edit(model);
    });

    item('CvUiModelEdit subList', () async {
      var model = lastModel = (_MyModel()
        ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 3))
        ..dummy.v = _Dummy());
      model = _MyModel()..subList.v = model.subList.v;
      await edit(model);
    });
  });
}
