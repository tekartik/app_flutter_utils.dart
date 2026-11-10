# tekartik_app_rx_bloc_flutter

The Flutter bundle of the Tekartik rx bloc stack: a bloc holding its state in
an rxdart `BehaviorSubject` (`AutoDisposeStateBaseBloc`), an "auto dispose"
registry (`audiAdd*`) that closes the subscriptions, subjects, controllers
and notifiers a bloc or a widget state owns, `BlocProvider` to provide the
bloc and `ValueStreamBuilder` to rebuild on its state.

It re-exports
[tekartik_app_rx_bloc](https://github.com/tekartik/app_common_utils.dart/tree/master/app_rx_bloc),
[tekartik_app_flutter_bloc](../app_bloc) (`BlocProvider`, `BaseBloc`) and
[tekartik_app_rx_utils](../app_rx_utils) (`ValueStreamBuilder`, rxdart).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_rx_bloc_flutter:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_rx_bloc
```

A counter (complete app in [example/main.dart](example/main.dart)):

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';

class CounterBloc extends AutoDisposeStateBaseBloc<int> {
  var _count = 0;

  CounterBloc() {
    add(_count);
  }

  void increment() => add(++_count);
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      body: Center(
        child: ValueStreamBuilder<int>(
          stream: bloc.state,
          builder: (context, snapshot) => Text('${snapshot.data}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: bloc.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: BlocProvider<CounterBloc>(
        blocBuilder: () => CounterBloc(),
        child: const CounterPage(),
      ),
    ),
  );
}
```

Platforms: every Flutter platform. `app_rx_bloc.dart` has no Flutter
dependency: blocs written with it run (and are tested) on the plain Dart VM.

## What to use

- `package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart` in widgets,
  `package:tekartik_app_rx_bloc_flutter/app_rx_bloc.dart` (no Flutter) in
  bloc and model files.
- `AutoDisposeStateBaseBloc<T>`: `state` (a `ValueStream<T>`, no value until
  the first `add`), `add(state)`, `addError(error)`, `dispose()`,
  `disposed`.
- `audiAddStreamSubscription`, `audiAddStreamController`,
  `audiAddBehaviorSubject`, `audiAddDisposable`, `audiAdd(object, dispose)`:
  register what you create, `dispose()` releases it all (`audiDisposeAll`).
  `audiAddValueNotifier` and `audiAddTextEditingController` come with
  `app_rx_flutter.dart`.
- `AutoDisposeBaseState<MyWidget>` instead of `State<MyWidget>`: the same
  `audi*` API in a widget state, released in its `dispose()`.
- `BlocProvider<T>(blocBuilder:, child:)` creates the bloc once and
  disposes it; `BlocProvider.of<T>(context)` finds it below.
- `ValueStreamBuilder<T>(stream: bloc.state, builder:)`: a `StreamBuilder`
  starting with the current value (no empty first frame).

## Common pitfalls

- `add` after `dispose` throws (`Cannot add new events after calling
  close`): check `disposed` after an `await`.
- `state` has no value until the first `add`: `snapshot.data` is null in the
  first build unless the constructor adds one.
- Never dispose a bloc given to a `BlocProvider` yourself, and never create a
  bloc (or subscribe) in `build()`.
- An override of `dispose()` must call `super.dispose()`, which releases
  every `audi*` registration.
- `BlocProvider.of<T>` needs a context below the provider (a child widget or
  a `Builder`) and the exact type `T`.

Agent skill:
[tekartik-app-rx-bloc-flutter-setup](skills/tekartik-app-rx-bloc-flutter-setup/SKILL.md).
