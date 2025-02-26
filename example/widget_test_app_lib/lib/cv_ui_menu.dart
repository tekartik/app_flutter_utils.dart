import 'package:cv/cv.dart';
import 'package:cv/utils/value_utils.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_utils/common_utils_import.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
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

class CvUiBasicTypeFieldValue extends StatelessWidget {
  final CvField<Object?> field;
  const CvUiBasicTypeFieldValue({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return CvUiStringFieldValue(
        field: CvField<String>(field.name, field.value?.toString()));
  }
}

class CvUiStringFieldValue extends StatelessWidget {
  final CvField<String> field;

  const CvUiStringFieldValue({super.key, required this.field});
  @override
  Widget build(BuildContext context) {
    return CvUiFieldWithChild(
      name: field.name,
      child: field.hasValue
          ? CvUiTextValue(text: field.value)
          : const CvUiUnsetValue(),
    );
  }
}

class CvUiUnsetValue extends StatelessWidget {
  const CvUiUnsetValue({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('unset',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
  }
}

class CvUiNullValue extends StatelessWidget {
  const CvUiNullValue({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('null', style: TextStyle(color: Colors.grey));
  }
}

class CvUiTextValue extends StatelessWidget {
  final String? text;
  const CvUiTextValue({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    var text = this.text;

    if (text == null) {
      return const CvUiNullValue();
    }
    return Text(text);
  }
}

class CvUiFieldLabel extends StatelessWidget {
  final String name;
  const CvUiFieldLabel({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextTheme.of(context).labelSmall,
    );
  }
}

class CvUiFieldWithChild extends StatelessWidget {
  final String name;
  final Widget? child;
  final bool? indented;
  const CvUiFieldWithChild({
    required this.name,
    this.child,
    this.indented,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CvUiFieldLabel(name: name),
          if (child != null)
            if (indented ?? false)
              Padding(padding: const EdgeInsets.only(left: 16), child: child)
            else
              child!
        ]);
  }
}

class CvUiModelValue extends StatelessWidget {
  final CvModel model;
  const CvUiModelValue({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    Widget buildField(CvField field) {
      if (!field.hasValue) {
        return const CvUiUnsetValue();
      }
      var value = field.value;
      if (value == null) {
        return const CvUiNullValue();
      } else if (field.type.isBasicType) {
        return CvUiBasicTypeFieldValue(field: field);
      } else if (field is CvModelField) {
        return CvUiFieldWithChild(
            indented: true,
            name: field.name,
            child: CvUiModelValue(model: field.value!));
      }
      return Text('Unsupported type ${field.type}');
    }

    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var field in model.fields) buildField(field),
      ],
    );
  }
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
