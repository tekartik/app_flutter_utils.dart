import 'package:cv/cv.dart';
import 'package:cv/utils/value_utils.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/src/confirm_dialog.dart';

import '../src/cv_ui_impl.dart';

var debugCvUi = false;

void _log(Object? message) {
  // ignore: avoid_print
  print(message);
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

class CvUiListItemLabel extends StatelessWidget {
  final int index;

  const CvUiListItemLabel({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Text(
      'item $index',
      style: TextTheme.of(context).labelSmall
        ?..copyWith(fontStyle: FontStyle.italic),
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

Widget _column({required List<Widget> children}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: children,
  );
}

class _ListChildren extends StatefulWidget {
  final List<Widget> children;

  const _ListChildren({required this.children});

  @override
  State<_ListChildren> createState() => _ListChildrenState();
}

class _ListChildrenState extends State<_ListChildren> {
  @override
  Widget build(BuildContext context) {
    var controller = CvUiModelViewProviderImpl.of(context);
    var editController =
        controller is CvUiModelEditControllerImpl ? controller : null;
    return _column(children: [
      ...widget.children.indexed.map((entry) {
        return CvUiListItemWithChild(
            index: entry.$1, indented: true, child: entry.$2);

        /*
        //return CvUiFieldWithChild(name: name)
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            const Text('-'),
            child,
          ],
        );*/
      }),
      if (editController != null)
        IconButton(
          iconSize: 16,
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.add,
          ),
          onPressed: () async {
            var result = await editController.add(context, widget);
            if (result) {
              setState(() {});
            }
          },
        ),
    ]);
  }
}

class _MapChildren extends StatelessWidget {
  final Map<String, Widget> children;
  final bool? indented;

  const _MapChildren({required this.children, required this.indented});

  @override
  Widget build(BuildContext context) {
    return _column(
      children: children
          .map((key, value) {
            return MapEntry(
                key,
                CvUiFieldWithChild(
                  name: key,
                  indented: indented,
                  child: value,
                ));
          })
          .values
          .toList(),
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
    return _ListChildren(
        children: list.map((item) {
      return CvUiTextValue(text: item.toString());
    }).toList());
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
    return _MapChildren(
        indented: true,
        children: map.map((key, model) {
          return MapEntry(key, CvUiModelValue(model: model));
        }));
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
    return _ListChildren(
        children: list.map((item) {
      return CvUiModelValue(model: item);
    }).toList());
  }
}

class CvUiListItemWithChild extends StatelessWidget {
  final int index;
  final Widget? child;
  final bool? indented;

  const CvUiListItemWithChild({
    required this.index,
    this.child,
    this.indented,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CvUiWidgetWithChild(
        widget: CvUiListItemLabel(index: index),
        indented: indented,
        child: child);
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
    return CvUiWidgetWithChild(
        widget: CvUiFieldLabel(name: name), indented: indented, child: child);
  }
}

class CvUiWidgetWithChild extends StatefulWidget {
  final Widget widget;
  final Widget? child;
  final bool? indented;

  const CvUiWidgetWithChild({
    required this.widget,
    this.child,
    this.indented,
    super.key,
  });

  @override
  State<CvUiWidgetWithChild> createState() => _CvUiWidgetWithChildState();
}

// reused but never disposed
var _textFieldController = TextEditingController();

class _CvUiWidgetWithChildState extends State<CvUiWidgetWithChild> {
  void _edit() async {
    var controller = CvUiModelEditProviderImpl.of(context);
    var result = await controller?.edit(context, widget);
    if (result == true) {
      setState(() {});
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    var controller = CvUiModelViewProviderImpl.of(context);
    var editController =
        controller is CvUiModelEditControllerImpl ? controller : null;
    var indented = widget.indented ?? false;
    var childWidget = indented
        ? Padding(padding: const EdgeInsets.only(left: 16), child: widget.child)
        : widget.child;

    var mainWidget = widget.widget;
    var expanded = true;
    if (controller != null && indented) {
      expanded = controller.isWidgetExpanded(widget);
      mainWidget = InkWell(
        onTap: () {
          setState(() {
            // ignore: unused_local_variable
            var result = controller.toggleWidget(widget);
            //print('selectField $this $result');
          });
        },
        child: Row(
          children: [
            mainWidget,
            Icon(
              expanded ? Icons.arrow_drop_down : Icons.arrow_right,
              size: 16,
            )
          ],
        ),
      );
    }
    var view = _column(children: [
      mainWidget,
      if ((childWidget != null) && expanded) childWidget
    ]);
    if (editController != null && childWidget != null) {
      // && !indented) {
      view = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            iconSize: 8,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.edit,
            ),
            onPressed: () {
              _edit();
              //      editController.editField(widget);
            },
          ),
          view,
        ],
      );
    }
    return view;
  }
}

class CvUiModelValueEdit extends StatelessWidget {
  final CvModel model;
  final CvUiValueRef ref;

  const CvUiModelValueEdit({super.key, required this.model, required this.ref});

  @override
  Widget build(BuildContext context) {
    return CvUiModelValue(model: model);
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
        return CvUiFieldWithChild(
            name: field.name, child: const CvUiNullValue());
      } else if (field.type.isBasicType) {
        return CvUiBasicTypeFieldValue(field: field);
      } else if (field is CvModelField) {
        return CvUiFieldWithChild(
            indented: true,
            name: field.name,
            child: CvUiModelValue(model: field.value!));
      } else if (field is CvModelListField) {
        return CvUiFieldWithChild(
            indented: true,
            name: field.name,
            child: CvUiModelListValue(
              list: field.value,
            ));
      } else if (field is CvListField) {
        return CvUiFieldWithChild(
            indented: true,
            name: field.name,
            child: CvUiListValue(list: field.value));
      } else if (field is CvModelMapField) {
        var value = field.value;
        return CvUiFieldWithChild(
            indented: true,
            name: field.name,
            child: CvUiModelMapValue(map: value));
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
      children: [
        for (var field in model.fields) buildField(field),
      ],
    );
  }
}

/// View controller
class CvUiModelViewController {
  factory CvUiModelViewController() => CvUiModelViewControllerImpl();
}

/// View controller
class CvUiModelEditController {
  factory CvUiModelEditController({required CvModel model}) =>
      CvUiModelEditControllerImpl(model: model);
}

abstract class CvUiValueRef {
  /// Path to the value
  List<Object> get pathParts;

  factory CvUiValueRef({required List<Object> pathParts}) {
    var lastPart = pathParts.last;
    if (lastPart is int) {
      return CvUiListItemValueRef(index: lastPart, pathParts: pathParts);
    } else if (lastPart is String) {
      return CvUiFieldValueRef(key: lastPart, pathParts: pathParts);
    } else {
      throw UnsupportedError('Unsupported type $lastPart');
    }
  }
}

abstract class _CvUiValueRefBase implements CvUiValueRef {
  @override
  final List<Object> pathParts;

  _CvUiValueRefBase({required this.pathParts});

  @override
  String toString() => pathParts.join('.');
}

class CvUiFieldValueRef extends _CvUiValueRefBase {
  final String key;

  CvUiFieldValueRef({required this.key, required super.pathParts});
}

class CvUiListItemValueRef extends _CvUiValueRefBase {
  final int index;

  CvUiListItemValueRef({required this.index, required super.pathParts});
}

enum CvUiEditResultType { cancel, ok, nullify, delete }

/// View controller private implementation
class CvUiModelEditControllerImpl extends CvUiModelViewControllerImpl
    implements CvUiModelEditController {
  CvUiModelEditControllerImpl({required this.model});

  void Function()? triggerRedraw;

  final CvModel model;

  @override
  String toString() => 'CvUiModelEditController()';

  CvModelTreeValue _widgetTreePath(BuildContext context, Widget widget) {
    var paths = <Object>[];
    context.visitAncestorElements((visitor) {
      var widget = visitor.widget;
      if (widget is CvUiFieldWithChild) {
        paths.insert(0, widget.name);
      } else if (widget is CvUiListItemWithChild) {
        paths.insert(0, widget.index);
      } else if (widget is CvUiModelEdit) {
        return false;
      }
      return true;
    });
    var tmv = model.cvTreeValueAtPath(CvTreePath(paths));
    if (debugCvUi) {
      _log('tmv $tmv');
    }
    return tmv;
  }

  Future<bool> add(BuildContext context, Widget widget) async {
    var tmv = _widgetTreePath(context, widget);

    var type = tmv.listItemType;
    // print('type $type');
    //var field = tmv.field;
    //var parts = tmv.treePath.parts;
    if (type?.isBasicType ?? false) {
      var result = await editText(
        context,
        title: 'Add',
      );
      if (result?.type == CvUiEditResultType.delete) {
      } else if (result?.type == CvUiEditResultType.nullify) {
      } else if (result?.type == CvUiEditResultType.ok) {
        var value = basicTypeCastType(type!, result?.value);
        // Get parent
        //var tmvParent =
        //    model.cvTreeValueAtPath(CvTreePath(parts.take(parts.length - 1)));

        var parentValue = tmv.value;

        if (parentValue is List) {
          parentValue.add(value);
        }

        /*
          if (parentValue is CvModel) {
            parentValue.field(last)!.clear();
          }
          if (parentValue is Map) {
            parentValue.remove(last);
          }*/
      }
      triggerRedraw?.call();
      return true;
    }
    return false;
  }

  // print('result $tmv');
  Future<bool> edit(BuildContext context, Widget widget) async {
    var tmv = _widgetTreePath(context, widget);
    // print('result $tmv');

    var value = tmv.value;

    var type = tmv.type;
    //var field = tmv.field;
    var parts = tmv.treePath.parts;
    if (type.isBasicType) {
      var result =
          await editText(context, title: 'Edit', value: value?.toString());
      if (result?.type == CvUiEditResultType.delete) {
        if (parts.length == 1) {
          model.field(parts.first as String)?.clear();
        } else {
          // Get parent
          var tmvParent =
              model.cvTreeValueAtPath(CvTreePath(parts.take(parts.length - 1)));

          var last = parts.last;
          var parentValue = tmvParent.value;
          if (last is int) {
            if (parentValue is List) {
              parentValue.removeAt(last);
            }
          } else if (last is String) {
            if (parentValue is CvModel) {
              parentValue.field(last)!.clear();
            }
            if (parentValue is Map) {
              parentValue.remove(last);
            }
          }
        }
        //tmv.clear();
      } else if (result?.type == CvUiEditResultType.nullify) {
        tmv.setValue(null, presentIfNull: true);
      } else if (result?.type == CvUiEditResultType.ok) {
        var value = basicTypeCastType(type, result?.value);
        tmv.setValue(value);
      }
      triggerRedraw?.call();
      return true;
    }
    return false;
  }

  /// Show a dialog to get a string
  ///
  /// returns null on cancel
  Future<CvUiEditTextResult?> editText(BuildContext context,
      {
      /// initial value
      String? value,
      String? title,
      FormFieldValidator<String>? validator,
      String? hint}) async {
    _textFieldController.dispose();
    _textFieldController = TextEditingController(text: value);
    return await showDialog<CvUiEditTextResult>(
        context: context,
        builder: (context) {
          final formKey = GlobalKey<FormState>();
          return AlertDialog(
            title: (title != null) ? Text(title) : null,
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: _textFieldController,
                decoration: InputDecoration(hintText: hint),
                validator: validator,
              ),
            ),
            actions: <Widget>[
              DialogButton(
                onPressed: () {
                  () async {
                    formKey.currentState!.save();
                    if (formKey.currentState!.validate()) {
                      var text = _textFieldController.text;
                      Navigator.of(context).pop(CvUiEditTextResult(
                          type: CvUiEditResultType.ok, value: text));
                    }
                  }();
                },
                text: 'OK',
              ),
              DialogButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: 'CANCEL',
              ),
              DialogButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(CvUiEditTextResult(type: CvUiEditResultType.delete));
                },
                text: 'DELETE',
              ),
              DialogButton(
                onPressed: () {
                  Navigator.of(context).pop(
                      CvUiEditTextResult(type: CvUiEditResultType.nullify));
                },
                text: 'NULLIFY',
              )
            ],
          );
        });
  }
}

class CvUiModelViewProvider {
  static CvUiModelViewController? of(BuildContext context) =>
      CvUiModelViewProviderImpl.of(context);
}

/// View controller private implementation
class CvUiModelViewProviderImpl {
  static CvUiModelViewControllerImpl? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CvUiModelViewProvider>()
        ?.controller;
  }
}

class _CvUiModelViewProvider extends InheritedWidget {
  final CvUiModelViewControllerImpl controller;

  const _CvUiModelViewProvider({
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(_CvUiModelViewProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// View controller private implementation
class CvUiModelEditProviderImpl {
  static CvUiModelEditControllerImpl? of(BuildContext context) {
    var viewController = CvUiModelViewProvider.of(context);
    if (viewController is CvUiModelEditControllerImpl) {
      return viewController;
    }
    return null;
  }
}

class CvUiModelView extends StatefulWidget {
  final CvUiModelViewController? controller;
  final CvModel model;

  const CvUiModelView({super.key, required this.model, this.controller});

  @override
  State<CvUiModelView> createState() => _CvUiViewState();
}

class _CvUiViewState extends State<CvUiModelView> {
  late final CvUiModelViewControllerImpl controller =
      (widget.controller as CvUiModelViewControllerImpl?) ??
          CvUiModelViewControllerImpl();

  @override
  Widget build(BuildContext context) {
    var model = widget.model;
    return _CvUiModelViewProvider(
      controller: controller,
      child: CvUiModelValue(model: model),
    );
  }
}

class CvUiModelEdit extends StatefulWidget {
  final CvUiModelEditController controller;

  const CvUiModelEdit({super.key, required this.controller});

  @override
  State<CvUiModelEdit> createState() => _CvUiEditState();
}

class _CvUiEditState extends State<CvUiModelEdit> {
  late final CvUiModelEditControllerImpl controller =
      (widget.controller as CvUiModelEditControllerImpl?) ??
          CvUiModelEditControllerImpl(model: CvMapModel());
  @override
  void initState() {
    controller.triggerRedraw = () {
      setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var model = controller.model;
    return _CvUiModelViewProvider(
      controller: controller,
      child: CvUiModelValue(model: model),
    );
  }
}

class CvUiEditTextResult {
  final CvUiEditResultType type;
  final String? value;

  CvUiEditTextResult({required this.type, this.value});
}
