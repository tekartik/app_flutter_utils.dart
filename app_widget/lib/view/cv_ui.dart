import 'package:cv/cv.dart';
import 'package:cv/utils/value_utils.dart';
import 'package:flutter/material.dart';

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
        return CvUiFieldWithChild(
            name: field.name, child: const CvUiUnsetValue());
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
