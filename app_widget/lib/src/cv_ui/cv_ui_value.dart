import 'package:cv/cv.dart';
import 'package:cv/utils/value_utils.dart';
import 'package:flutter/material.dart';

import 'cv_ui_impl.dart';
import 'cv_ui_layout.dart';

class CvUiUnsetValue extends StatelessWidget {
  const CvUiUnsetValue({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'unset',
      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
    );
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

class CvUiBasicTypeFieldValue extends StatelessWidget {
  final CvField<Object?> field;

  const CvUiBasicTypeFieldValue({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return CvUiStringFieldValue(
      field: CvField<String>(field.name, field.value?.toString()),
    );
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

class CvUiListValue extends StatelessWidget {
  final List? list;

  const CvUiListValue({super.key, this.list});

  @override
  Widget build(BuildContext context) {
    var list = this.list;

    if (list == null) {
      return const CvUiNullValue();
    }
    return CvUiListChildrenPrv(
      children: list.map((item) {
        return CvUiTextValue(text: item.toString());
      }).toList(),
    );
  }
}

/// Typically for model map (`Map<String, CvModel>`)
class CvUiModelMapValue extends StatelessWidget {
  final Map<String, CvModel>? map;

  const CvUiModelMapValue({super.key, this.map});

  @override
  Widget build(BuildContext context) {
    var map = this.map;

    if (map == null) {
      return const CvUiNullValue();
    }
    return CvUiMapChildrenPrv(
      indented: true,
      children: map.map((key, model) {
        return MapEntry(key, CvUiModelValue(model: model));
      }),
    );
  }
}

class CvUiModelListValue extends StatelessWidget {
  final List<CvModel>? list;

  const CvUiModelListValue({super.key, this.list});

  @override
  Widget build(BuildContext context) {
    var list = this.list;

    if (list == null) {
      return const CvUiNullValue();
    }
    return CvUiListChildrenPrv(
      children: list.map((item) {
        return CvUiModelValue(model: item);
      }).toList(),
    );
  }
}

class CvUiModelValue extends StatefulWidget {
  final CvModel model;

  const CvUiModelValue({super.key, required this.model});

  @override
  State<CvUiModelValue> createState() => _CvUiModelValueState();
}

class _CvUiModelValueState extends State<CvUiModelValue> {
  @override
  Widget build(BuildContext context) {
    Widget buildField(CvField field) {
      if (!field.hasValue) {
        return CvUiFieldWithChild(
          name: field.name,
          child: const CvUiUnsetValue(),
        );
      }
      var value = field.value;
      if (value == null) {
        return CvUiFieldWithChild(
          name: field.name,
          child: const CvUiNullValue(),
        );
      } else if (field.type.isBasicType) {
        return CvUiBasicTypeFieldValue(field: field);
      } else if (field is CvModelField) {
        return CvUiFieldWithChild(
          indented: true,
          name: field.name,
          child: CvUiModelValue(model: field.value!),
        );
      } else if (field is CvModelListField) {
        return CvUiFieldWithChild(
          indented: true,
          name: field.name,
          child: CvUiModelListValue(list: field.value),
        );
      } else if (field is CvListField) {
        return CvUiFieldWithChild(
          indented: true,
          name: field.name,
          child: CvUiListValue(list: field.value),
        );
      } else if (field is CvModelMapField) {
        var value = field.value;
        return CvUiFieldWithChild(
          indented: true,
          name: field.name,
          child: CvUiModelMapValue(map: value),
        );
      }
      return Text(
        'Unsupported type ${field.type}',
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      );
    }

    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [for (var field in widget.model.fields) buildField(field)],
    );
  }
}
