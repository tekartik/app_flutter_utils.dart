---
name: tekartik-app-flutter-bloc-provider
description: >-
  Use when a Flutter widget tree needs a plain BaseBloc (tekartik_app_bloc)
  created once, found by type from descendants and disposed with the tree,
  using tekartik_app_flutter_bloc: BlocProvider, BlocProvider.of<T>(context),
  blocBuilder, BaseBloc.dispose/disposed, the bloc_provider.dart import, and
  testing a bloc in widget tests with pumpWidget.
---

# BlocProvider for BaseBloc (tekartik_app_flutter_bloc)

`tekartik_app_flutter_bloc` is a tiny provider: `BlocProvider<T>` creates one
`BaseBloc` subclass when it is mounted, exposes it to descendants through
`BlocProvider.of<T>(context)` and calls `dispose()` on it when the provider
leaves the tree. It has no state management of its own: the bloc exposes
streams or listenables, widgets rebuild with `StreamBuilder` or
`ValueListenableBuilder`.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_bloc:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_bloc
  ```
  Import `package:tekartik_app_flutter_bloc/bloc_provider.dart`; it
  re-exports `package:tekartik_app_bloc/base_bloc.dart` (`BaseBloc`), so no
  second import or dependency is needed for the base class.
* A bloc is a class extending `BaseBloc`. `BaseBloc` only provides
  `dispose()` (annotated `@mustCallSuper`) and the `disposed` getter. Own the
  async resources in the subclass (`StreamController`, subscriptions,
  timers), close them in `dispose()` and finish with `super.dispose()`. Check
  `disposed` before touching controllers in late callbacks.
* Mount with `BlocProvider(blocBuilder: () => MyBloc(), child: ...)`. The
  type parameter `T` is inferred from `blocBuilder`'s return type; make it the
  concrete bloc class (write `BlocProvider<MyBloc>(...)` explicitly when the
  builder returns a supertype), because `of<T>` looks up the inherited widget
  of the exact type `T`.
* `blocBuilder` runs once, in `initState`, so it may create controllers and
  start work; it receives no `context`. The instance survives rebuilds of the
  provider widget and is disposed once, in the provider's `dispose`.
* Read with `BlocProvider.of<MyBloc>(context)` from any descendant `context`
  (a `Builder`, a `State`'s `context`, including in `initState`). It throws a
  `TypeError` when no `BlocProvider<MyBloc>` is above that context; the widget
  that creates the provider cannot call `of` with its own context, wrap the
  consumer in a `Builder` or a separate widget.
* `of` registers no dependency (`updateShouldNotify` is `false` and the lookup
  uses `getElementForInheritedWidgetOfExactType`): widgets never rebuild
  because of the provider. React to bloc changes with `StreamBuilder`,
  `ValueListenableBuilder` or `AnimatedBuilder` on what the bloc exposes.
* One provider per bloc type: nest `BlocProvider` widgets for several blocs; a
  nested provider of the same `T` shadows the outer one.
* Scope the provider to the lifetime you want: above the `Scaffold` of a page
  (the bloc dies with the page) or around `MaterialApp` for an app-wide bloc.
* Tests: `tester.pumpWidget(...)` a `BlocProvider` around the widget under
  test with a real or fake bloc; the bloc is disposed when the test tree is
  torn down. Blocs are plain Dart objects: unit test them without Flutter.

## Examples

### A bloc with a stream, its provider and consumers

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';

class CounterBloc extends BaseBloc {
  final _controller = StreamController<int>.broadcast();
  var _count = 0;

  Stream<int> get count => _controller.stream;

  void increment() {
    if (!disposed) {
      _controller.add(++_count);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      blocBuilder: () => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Counter')),
        body: const Center(child: CounterText()),
        // Builder: a context below the provider.
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => BlocProvider.of<CounterBloc>(context).increment(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<CounterBloc>(context);
    return StreamBuilder<int>(
      stream: bloc.count,
      initialData: 0,
      builder: (context, snapshot) => Text('${snapshot.data}'),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: CounterPage()));
}
```

### Widget test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';

class TestBloc extends BaseBloc {
  final String value = 'test_result';
}

void main() {
  testWidgets('BlocProvider.of', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          blocBuilder: () => TestBloc(),
          child: Builder(
            builder: (context) =>
                Text(BlocProvider.of<TestBloc>(context).value),
          ),
        ),
      ),
    );
    expect(find.text('test_result'), findsOneWidget);
  });
}
```

## Common mistakes

* Calling `BlocProvider.of` with the context of the widget that builds the
  provider (nothing is above it yet).
* Letting `T` be inferred as `BaseBloc` and then asking for
  `of<MyBloc>`: the exact-type lookup fails.
* Expecting consumers to rebuild when the bloc changes: use a stream or a
  listenable exposed by the bloc.
* Forgetting `super.dispose()` in the bloc's `dispose` override.
