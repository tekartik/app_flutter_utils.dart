---
name: tekartik-app-rx-bloc-flutter-setup
description: >-
  Use when a Flutter screen needs an rxdart based bloc whose subscriptions and
  controllers are released automatically, with tekartik_app_rx_bloc_flutter:
  the app_rx_flutter.dart and app_rx_bloc.dart imports, AutoDisposeStateBaseBloc
  and StateBaseBloc (state ValueStream, add, addError, dispose),
  AutoDisposeBaseState for a StatefulWidget, the audi* helpers (audiAdd,
  audiAddStreamSubscription, audiAddStreamController, audiAddBehaviorSubject,
  audiAddValueNotifier, audiAddTextEditingController, audiAddDisposable,
  audiDisposeAll), AutoDispose / AutoDisposeMixin / AutoDisposableMixin /
  AutoDisposerableBase, plus the re-exported BlocProvider, ValueStreamBuilder,
  BehaviorSubjectBuilder and rxdart BehaviorSubject / ValueStream.
---

# Auto disposing rx blocs for Flutter (tekartik_app_rx_bloc_flutter)

This package is the Flutter bundle of the tekartik rx/bloc stack: a bloc base
class holding a `BehaviorSubject` state, an "auto dispose" registry (`audi*`)
that closes everything the bloc or the widget state owns, and the widgets
needed to provide and rebuild on that state.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_rx_bloc_flutter:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_rx_bloc
  ```
* Two public libraries, never import anything under `lib/src/`:
  * `package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart` - the one to
    use from app code. It re-exports `app_rx_bloc.dart` plus `BlocProvider`
    and `BaseBloc` (from `tekartik_app_flutter_bloc`), `ValueStreamBuilder`
    and `BehaviorSubjectBuilder` (from `tekartik_app_rx_utils`),
    `AutoDisposeBaseState` and the `AutoDisposeValueNotifierExtension`.
  * `package:tekartik_app_rx_bloc_flutter/app_rx_bloc.dart` - the Flutter free
    part: `StateBaseBloc`, `AutoDisposeStateBaseBloc`, the `AutoDispose` API
    and all of `rxdart` (`BehaviorSubject`, `ValueStream`, `PublishSubject`,
    ...). Use it in pure Dart bloc/model files so they stay testable with
    `package:test`.
* Bloc: extend `AutoDisposeStateBaseBloc<T>` (`StateBaseBloc<T>` +
  `AutoDisposeMixin` + `AutoDisposableMixin`). It gives
  `ValueStream<T> get state`, `void add(T state)`,
  `void addError(Object error, [StackTrace? stackTrace])`, `void dispose()`
  and `bool get disposed`. `state` has no value until the first `add`, so
  widgets must handle `snapshot.data == null`.
* Register every resource with an `audi*` method as soon as you create it;
  `dispose()` calls `audiDisposeAll()` for you (override `dispose()` only
  with `@mustCallSuper` / `super.dispose()`):
  * `audiAddStreamSubscription(sub)` - cancels it.
  * `audiAddStreamController(controller)` / `audiAddBehaviorSubject(subject)`
    - closes it.
  * `audiAddValueNotifier(notifier)` / `audiAddTextEditingController(ctlr)` -
    disposes it (Flutter extension, `app_rx_flutter.dart` only).
  * `audiAddDisposable(obj)` - for any `AutoDisposable` (calls `selfDispose`).
  * `audiAdd(obj, disposeFn)`, `audiAddSelf(obj, (o) => ...)` or
    `audiAddFunction(fn)` for anything else. Each returns the object, so
    `late final x = audiAdd...(X())` is the idiomatic declaration.
  * `audiDispose(obj)` / `audiDisposeFunction(fn)` release one item early.
* Widget state: extend `AutoDisposeBaseState<MyWidget>` instead of
  `State<MyWidget>` to get the same `audi*` API in a `StatefulWidget`; its
  `dispose()` already calls `audiDisposeAll()`. For a non widget, non bloc
  helper class use `AutoDisposerableBase` (or `with AutoDisposeMixin`).
* Provide a bloc with `BlocProvider<T>(blocBuilder: () => T(), child: ...)`
  and read it with `BlocProvider.of<T>(context)`. The provider builds the bloc
  once in `initState` and disposes it when removed, so never dispose a
  provided bloc yourself, and never create a bloc in `build()`.
* Rebuild on the bloc state with `ValueStreamBuilder<T>(stream: bloc.state,
  builder: ...)` (or `BehaviorSubjectBuilder<T>(subject: ...)` when you hold
  the subject): both seed `StreamBuilder.initialData` with the current value,
  which avoids the one frame flash of a raw `StreamBuilder`.
* Anti-patterns: calling `add()` after `dispose()` (check `disposed`), storing
  a `BehaviorSubject` without `audiAddBehaviorSubject`, subscribing in
  `build()`, and exposing the raw subject instead of `state` (a `ValueStream`,
  read only).
* Tests: a bloc built on `app_rx_bloc.dart` needs no Flutter binding, so plain
  `package:test` works; use `flutter_test` + `pumpWidget` only for the widget
  parts. Always `dispose()` the bloc at the end of a test.

## Examples

### Counter bloc, provided and rendered

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';

class CounterBloc extends AutoDisposeStateBaseBloc<int> {
  var _count = 0;

  CounterBloc() {
    add(_count);
  }

  void increment() {
    if (!disposed) {
      add(++_count);
    }
  }
}

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      blocBuilder: () => CounterBloc(),
      child: Builder(
        builder: (context) {
          var bloc = BlocProvider.of<CounterBloc>(context);
          return Scaffold(
            body: Center(
              child: ValueStreamBuilder<int>(
                stream: bloc.state,
                builder: (context, snapshot) {
                  var count = snapshot.data;
                  if (count == null) {
                    return const CircularProgressIndicator();
                  }
                  return Text('$count');
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: bloc.increment,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
```

### Bloc owning a subscription and a subject

```dart
import 'dart:async';

import 'package:tekartik_app_rx_bloc_flutter/app_rx_bloc.dart';

class SearchState {
  final String query;
  final List<String> results;

  SearchState(this.query, this.results);
}

/// Pure dart bloc: no flutter import, testable with package:test.
class SearchBloc extends AutoDisposeStateBaseBloc<SearchState> {
  /// Closed by audiDisposeAll() in dispose().
  late final querySubject = audiAddBehaviorSubject(BehaviorSubject<String>());

  SearchBloc(Stream<String> externalQueries) {
    audiAddStreamSubscription(externalQueries.listen(querySubject.add));
    audiAddStreamSubscription(
      querySubject.stream.distinct().listen(_search, onError: addError),
    );
  }

  void _search(String query) {
    add(SearchState(query, <String>['$query 1', '$query 2']));
  }
}

Future<void> main() async {
  var controller = StreamController<String>();
  var bloc = SearchBloc(controller.stream);
  controller.add('hello');
  var state = await bloc.state.first;
  print('${state.query}: ${state.results}');
  bloc.dispose();
  await controller.close();
}
```

### Widget state with AutoDisposeBaseState

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';

class NameField extends StatefulWidget {
  final Stream<String> initialName;

  const NameField({super.key, required this.initialName});

  @override
  State<NameField> createState() => _NameFieldState();
}

/// AutoDisposeBaseState disposes everything added with audi* in dispose().
class _NameFieldState extends AutoDisposeBaseState<NameField> {
  late final textController = audiAddTextEditingController(
    TextEditingController(),
  );
  late final valid = audiAddValueNotifier(ValueNotifier<bool>(false));

  @override
  void initState() {
    super.initState();
    audiAddStreamSubscription(
      widget.initialName.listen((name) => textController.text = name),
    );
    textController.addListener(() {
      valid.value = textController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: valid,
      builder: (context, isValid, _) => TextField(
        controller: textController,
        decoration: InputDecoration(
          labelText: 'Name',
          errorText: isValid ? null : 'Required',
        ),
      ),
    );
  }
}
```

### Testing a bloc

```dart
import 'package:tekartik_app_rx_bloc_flutter/app_rx_bloc.dart';
import 'package:test/test.dart';

class CounterBloc extends AutoDisposeStateBaseBloc<int> {
  var _count = 0;

  void increment() => add(++_count);
}

void main() {
  test('counter', () async {
    var bloc = CounterBloc();
    expect(bloc.state.hasValue, isFalse);
    bloc.increment();
    expect(await bloc.state.first, 1);
    bloc.dispose();
    expect(bloc.disposed, isTrue);
  });
}
```
