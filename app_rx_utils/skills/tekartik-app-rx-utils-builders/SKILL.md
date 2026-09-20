---
name: tekartik-app-rx-utils-builders
description: >-
  Use when a Flutter widget must rebuild from an rxdart BehaviorSubject or
  ValueStream without the initial null frame of a raw StreamBuilder, with
  tekartik_app_rx_utils: the package:tekartik_app_rx_utils/app_rx_utils.dart
  import, BehaviorSubjectBuilder(subject:, builder:),
  ValueStreamBuilder(stream:, builder:), the AsyncWidgetBuilder /
  AsyncSnapshot builder signature, and the re-exported rxdart API
  (BehaviorSubject, ValueStream, PublishSubject, ReplaySubject, hasValue,
  value, close).
---

# Rx subject builders (tekartik_app_rx_utils)

Two thin `StatelessWidget` wrappers around `StreamBuilder` that seed
`initialData` with the current value of a `BehaviorSubject` / `ValueStream`,
so the first build already shows the value instead of an empty snapshot.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_rx_utils:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_rx_utils
      version: '>=0.1.0'
  ```
* One public library: `package:tekartik_app_rx_utils/app_rx_utils.dart`. It
  exports `BehaviorSubjectBuilder`, `ValueStreamBuilder` and all of
  `package:rxdart/rxdart.dart`, so a single import is enough for
  `BehaviorSubject`, `ValueStream`, `PublishSubject`, `ReplaySubject` and the
  rx operators. Never import anything under `lib/src/`.
* `ValueStreamBuilder<T>(stream: valueStream, builder: (context, snapshot) =>
  ...)` - the read only form. `stream` is a `ValueStream<T>`, which is what a
  bloc exposes (`BehaviorSubject` implements it, as does `stream` of a
  behavior subject). Prefer it in widgets: they get no way to push a value.
* `BehaviorSubjectBuilder<T>(subject: subject, builder: (context, snapshot) =>
  ...)` - same thing when you hold the `BehaviorSubject<T>` itself.
* `builder` is a plain `AsyncWidgetBuilder<T>`:
  `Widget Function(BuildContext context, AsyncSnapshot<T> snapshot)`. Both
  widgets pass `initialData: hasValue ? value : null`, so:
  * a subject that never received a value gives `snapshot.data == null` -
    handle it (`snapshot.data ?? fallback`, or a spinner);
  * with a value, the very first frame already has it, no flash;
  * errors added with `addError` arrive as `snapshot.hasError` /
    `snapshot.error`, they are not thrown.
* Always give the type argument (`ValueStreamBuilder<int>(...)`) when the
  builder body needs it; without it inference from an untyped stream can fall
  back to `dynamic`.
* Lifecycle: these widgets never create nor close the subject. Create it in
  `initState` (or in a bloc / controller) and `close()` it in `dispose`;
  building a subject inside `build()` leaks a controller on every rebuild.
* With `tekartik_app_rx_bloc_flutter` both widgets are already re-exported by
  `package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart`; do not add this
  package twice in that case.
* Tests: `flutter_test` + `tester.pumpWidget(...)`; after `subject.add(v)`
  pump again (`pumpWidget` / `pump()`) before asserting with `find.text(...)`,
  since the rebuild happens on the next frame.

## Examples

### Subject owned by a StatefulWidget

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final subject = BehaviorSubject<int>.seeded(0);

  @override
  void dispose() {
    subject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BehaviorSubjectBuilder<int>(
          subject: subject,
          builder: (context, snapshot) => Text('${snapshot.data ?? 0}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => subject.add(subject.value + 1),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Read only ValueStream exposed by a model

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';

class UserModel {
  final _name = BehaviorSubject<String>();

  /// Read only view, the widget cannot push a value.
  ValueStream<String> get name => _name.stream;

  void setName(String value) => _name.add(value);

  void addError(Object error) => _name.addError(error);

  Future<void> close() => _name.close();
}

class NameText extends StatelessWidget {
  final UserModel model;

  const NameText({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return ValueStreamBuilder<String>(
      stream: model.name,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        var name = snapshot.data;
        if (name == null) {
          return const CircularProgressIndicator();
        }
        return Text(name);
      },
    );
  }
}
```

### Widget test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';

void main() {
  testWidgets('value stream builder', (tester) async {
    var subject = BehaviorSubject<String>();
    var widget = Directionality(
      textDirection: TextDirection.ltr,
      child: ValueStreamBuilder<String>(
        stream: subject,
        builder: (context, snapshot) => Text(snapshot.data ?? ''),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text(''), findsOneWidget);

    subject.add('test');
    await tester.pumpWidget(widget);
    expect(find.text('test'), findsOneWidget);

    await subject.close();
  });
}
```

### Combining rx operators before building

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';

/// rxdart is re-exported, so operators need no extra import.
class FilteredList extends StatelessWidget {
  final ValueStream<List<String>> items;

  const FilteredList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ValueStreamBuilder<List<String>>(
      stream: items,
      builder: (context, snapshot) {
        var list = snapshot.data ?? <String>[];
        return ListView(
          children: [for (var item in list) ListTile(title: Text(item))],
        );
      },
    );
  }
}

/// A derived value stream, ready for another ValueStreamBuilder.
ValueStream<int> countOf(ValueStream<List<String>> items) {
  return items.map((list) => list.length).shareValue();
}
```
