---
name: tekartik-app-flutter-widget-cv-ui
description: >-
  Use when a Flutter screen must display or hand-edit a cv CvModel
  (debug/admin/dev inspector) with tekartik_app_flutter_widget's cv_ui: the
  package:tekartik_app_flutter_widget/view/cv_ui.dart import, CvUiModelView,
  CvUiModelEdit with CvUiModelEditController(model:) and
  CvUiModelViewController, the value widgets CvUiModelValue, CvUiTextValue,
  CvUiNullValue, CvUiUnsetValue, CvUiStringFieldValue,
  CvUiBasicTypeFieldValue, CvUiListValue, CvUiModelListValue,
  CvUiModelMapValue, the labels CvUiFieldLabel / CvUiListItemLabel,
  CvUiEditResultType and the debugCvUi flag.
---

# Generic cv model viewer/editor (tekartik_app_flutter_widget)

`view/cv_ui.dart` renders any `cv` `CvModel` as a collapsible field tree, and
optionally lets the user edit every value in place - a generic inspector for
debug, admin and dev screens, not a designed form.

## Guidelines

* Dependency (git, not on pub.dev); `cv` comes with it:
  ```yaml
  dependencies:
    tekartik_app_flutter_widget:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_widget
      version: '>=0.2.1'
  ```
* Import `package:tekartik_app_flutter_widget/view/cv_ui.dart` (plus
  `package:cv/cv.dart` for the model itself). Never import anything under
  `lib/src/`.
* Read only: `CvUiModelView(model: myModel)` walks `model.fields` and builds
  a label + value per field, recursing into `CvModelField`,
  `CvModelListField`, `CvListField` and `CvModelMapField`. Pass a
  `CvUiModelViewController()` if you want the expand/collapse state of the
  sub trees to survive a rebuild (the controller keeps it; nodes default to
  expanded).
* Editable: `CvUiModelEdit(controller: CvUiModelEditController(model:
  myModel))`. `controller` is required and holds the model. Each value then
  gets a small pencil button opening a dialog with OK / DELETE / NULLIFY (and
  CREATE for a model or list field), matching `CvUiEditResultType.ok`,
  `delete`, `nullify`, `create`, `cancel`.
* Editing mutates **your model instance in place** and redraws; there is no
  `onChanged` callback and no save step. Read the fields back from the model
  you passed (or `toMap()`) when the screen closes, and pass a copy if you
  need a cancel.
* For a sub model or a model list to be creatable while editing, register the
  constructors first with `cv`'s `cvAddConstructors([MyModel.new, ...])`
  (usually once at startup); without it the CREATE action cannot build the
  child.
* Value widgets can be used on their own, outside a model:
  `CvUiModelValue(model:)` (the field tree of one model),
  `CvUiTextValue(text:)`, `CvUiNullValue()` (grey `null`), `CvUiUnsetValue()`
  (italic `unset` - a `CvField` with no value differs from a null value),
  `CvUiStringFieldValue(field: CvField<String>('key', 'value'))`,
  `CvUiBasicTypeFieldValue(field:)` for any basic typed `CvField`,
  `CvUiListValue(list:)`, `CvUiModelListValue(list:)`,
  `CvUiModelMapValue(map:)`, and the labels `CvUiFieldLabel(name:)` /
  `CvUiListItemLabel(index:)`.
* A field whose type is not a basic type, a model, a list or a model map
  renders as `Unsupported type ...` - that is expected for custom objects.
* Set `debugCvUi = true` to print the resolved tree path of the value being
  edited; keep it `false` in production.
* Put the widget inside a scrollable (`ListView`, `SingleChildScrollView`)
  with some padding: it is an unbounded height `Column`, and a filled model
  gets tall quickly.

## Examples

### View a model

```dart
import 'package:cv/cv.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';

class Address extends CvModelBase {
  final street = CvField<String>('street');
  final city = CvField<String>('city');

  @override
  CvFields get fields => [street, city];
}

class User extends CvModelBase {
  final name = CvField<String>('name');
  final age = CvField<int>('age');
  final tags = CvListField<String>('tags');
  final address = CvModelField<Address>('address');

  @override
  CvFields get fields => [name, age, tags, address];
}

class UserViewPage extends StatelessWidget {
  final User user;

  const UserViewPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [CvUiModelView(model: user)],
      ),
    );
  }
}
```

### Edit a model in place

```dart
import 'package:cv/cv.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';

class Item extends CvModelBase {
  final label = CvField<String>('label');
  final count = CvField<int>('count');

  @override
  CvFields get fields => [label, count];
}

class Basket extends CvModelBase {
  final name = CvField<String>('name');
  final items = CvModelListField<Item>('items');

  @override
  CvFields get fields => [name, items];
}

/// Needed once so that CREATE can build sub models/lists.
void initCv() {
  cvAddConstructors([Item.new, Basket.new]);
}

class BasketEditPage extends StatelessWidget {
  final Basket basket;

  const BasketEditPage({super.key, required this.basket});

  @override
  Widget build(BuildContext context) {
    /// The model is edited in place, pop it back when done.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit basket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.of(context).pop(basket),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          CvUiModelEdit(
            controller: CvUiModelEditController(model: basket),
          ),
        ],
      ),
    );
  }
}

/// Edit a copy so that a cancel keeps the original untouched.
Future<Basket?> editBasket(BuildContext context, Basket original) async {
  var copy = Basket()..fromMap(original.toMap());
  return await Navigator.of(context).push<Basket>(
    MaterialPageRoute(builder: (_) => BasketEditPage(basket: copy)),
  );
}
```

### Individual value widgets

```dart
import 'package:cv/cv.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';

class ValueSamples extends StatelessWidget {
  const ValueSamples({super.key});

  @override
  Widget build(BuildContext context) {
    /// A field with a value, and one that was never set.
    var withValue = CvField<String>('someKey', 'someValue');
    var unset = CvField<String>('otherKey');

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        const CvUiFieldLabel(name: 'a label'),
        const CvUiTextValue(text: 'Hello'),
        const CvUiTextValue(),
        const CvUiNullValue(),
        const CvUiUnsetValue(),
        CvUiStringFieldValue(field: withValue),
        CvUiStringFieldValue(field: unset),
        CvUiBasicTypeFieldValue(field: CvField<int>('count', 3)),
        const CvUiListValue(list: [1, 2, 3]),
        const CvUiListItemLabel(index: 0),
      ],
    );
  }
}
```
