import 'package:cv/cv.dart';
import 'package:cv/utils/value_utils.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/src/confirm_dialog.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';

import 'cv_ui_edit_result.dart';
import 'cv_ui_impl.dart';

void _log(Object? message) {
  // ignore: avoid_print
  print(message);
}

/// View controller
class CvUiModelEditController {
  factory CvUiModelEditController({required CvModel model}) =>
      CvUiModelEditControllerImpl(model: model);
}

/// View controller
class CvUiModelViewController {
  factory CvUiModelViewController() => CvUiModelViewControllerImpl();
}

/// View controller private implementation
class CvUiModelViewControllerImpl implements CvUiModelViewController {
  /// Expanded widget
  final _expanded = <Widget, bool>{};

  /// Default to true
  bool isWidgetExpanded(Widget widget) => _expanded[widget] ?? true;

  /// Set widget expanded
  bool setWidgetExpanded(Widget widget, bool value) {
    _expanded[widget] = value;
    return value;
  }

  /// toggle the value, true if expanded
  bool toggleWidget(Widget widget, [bool? value]) {
    var expanded = value ?? !isWidgetExpanded(widget);
    // print('toggleWidget $expanded');
    return setWidgetExpanded(widget, expanded);
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
        .dependOnInheritedWidgetOfExactType<CvUiModelViewProviderPrv>()
        ?.controller;
  }
}

class CvUiModelViewProviderPrv extends InheritedWidget {
  final CvUiModelViewControllerImpl controller;

  const CvUiModelViewProviderPrv({
    super.key,
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(CvUiModelViewProviderPrv oldWidget) {
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
      var result = await editText(context, title: 'Add');
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
    } else {
      // List item?
      var child = tmv.listCreateItem<Object>();
      var existing = tmv.value! as List;
      existing.add(child);
      tmv.setValue(existing);
      triggerRedraw?.call();
      return true;
    }
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
      var result = await editText(
        context,
        title: 'Edit',
        value: value?.toString(),
      );
      if (result?.type == CvUiEditResultType.delete) {
        if (parts.length == 1) {
          model.field(parts.first as String)?.clear();
        } else {
          // Get parent
          var tmvParent = model.cvTreeValueAtPath(
            CvTreePath(parts.take(parts.length - 1)),
          );

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
    } else {
      var result = await _editCreateDeleteOrNullify(context, title: 'Edit');
      if (result?.type == CvUiEditResultType.delete) {
        if (parts.length == 1) {
          model.field(parts.first as String)?.clear();
        } else {
          // Get parent
          var tmvParent = model.cvTreeValueAtPath(
            CvTreePath(parts.take(parts.length - 1)),
          );

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
      } else if (result?.type == CvUiEditResultType.create) {
        if (parts.length == 1) {
          var parentField = model.field(parts.first as String);
          if (parentField is CvListField) {
            var value = parentField.createList();
            tmv.setValue(value);
          } else if (parentField is CvModelField) {
            var value = parentField.create({});
            tmv.setValue(value);
          } else {
            if (debugCvUi) {
              _log('invalid parent $parentField');
            }
          }
        }
        /*
          var value = listItemType.createValue();
          var parentValue = tmv.value;
          if (parentValue is List) {
            parentValue.add(value);
          }*/
      } else {
        if (debugCvUi) {
          _log('Invalid result $result');
        }
        return false;
      }
      triggerRedraw?.call();
      return true;
    }
  }

  /// Show a dialog to get a string
  ///
  /// returns null on cancel
  Future<CvUiEditTextResult?> editText(
    BuildContext context, {

    /// initial value
    String? value,
    String? title,
    FormFieldValidator<String>? validator,
    String? hint,
  }) async {
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
                    Navigator.of(context).pop(
                      CvUiEditTextResult(
                        type: CvUiEditResultType.ok,
                        value: text,
                      ),
                    );
                  }
                }();
              },
              text: 'OK',
            ),
            const _DeleteButton(),
            const _NullifyButton(),
            const _CancelButton(),
          ],
        );
      },
    );
  }

  /// Show a dialog to get a string
  ///
  /// returns null on cancel
  Future<CvUiEditResult?> _editCreateDeleteOrNullify(
    BuildContext context, {
    String? title,
  }) async {
    return await showDialog<CvUiEditResult>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: (title != null) ? Text(title) : null,
          actions: <Widget>[
            DialogButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(CvUiEditResult(type: CvUiEditResultType.create));
              },
              text: 'CREATE',
            ),
            const _DeleteButton(),
            const _NullifyButton(),
            const _CancelButton(),
          ],
        );
      },
    );
  }
}

class _NullifyButton extends StatelessWidget {
  const _NullifyButton({
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DialogButton(
      onPressed: () {
        Navigator.of(
          context,
        ).pop(CvUiEditTextResult(type: CvUiEditResultType.nullify));
      },
      text: 'NULLIFY',
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DialogButton(
      onPressed: () {
        Navigator.of(
          context,
        ).pop(CvUiEditTextResult(type: CvUiEditResultType.delete));
      },
      text: 'DELETE',
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DialogButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      text: 'CANCEL',
    );
  }
}

// reused but never disposed
var _textFieldController = TextEditingController();
