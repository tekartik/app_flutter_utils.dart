# tekartik_app_flutter_bloc

A tiny provider for a `BaseBloc` (of
[tekartik_app_bloc](https://github.com/tekartik/app_common_utils.dart/tree/master/app_bloc)):
`BlocProvider` creates the bloc once when it is mounted, descendants find it
with `BlocProvider.of<MyBloc>(context)`, and it is disposed when the provider
leaves the tree. No state management of its own: the bloc exposes streams or
listenables.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_bloc:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_bloc
```

`package:tekartik_app_flutter_bloc/bloc_provider.dart` exports `BaseBloc`
too. A counter (complete app in [example/main.dart](example/main.dart)):

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';

class CounterBloc extends BaseBloc {
  final _count = StreamController<int>.broadcast();
  var _value = 0;

  Stream<int> get count => _count.stream;

  void increment() => _count.add(++_value);

  @override
  void dispose() {
    _count.close();
    super.dispose();
  }
}

Widget counterPage() => BlocProvider<CounterBloc>(
  blocBuilder: () => CounterBloc(),
  // A context below the provider.
  child: Builder(
    builder: (context) {
      var bloc = BlocProvider.of<CounterBloc>(context);
      return GestureDetector(
        onTap: bloc.increment,
        child: StreamBuilder<int>(
          stream: bloc.count,
          initialData: 0,
          builder: (context, snapshot) => Text('${snapshot.data}'),
        ),
      );
    },
  ),
);
```

Platforms: every Flutter platform (plain widgets, no material).

## Common pitfalls

- `of<T>` finds the provider of the exact type `T`: write
  `BlocProvider<MyBloc>(...)` when `blocBuilder` returns a supertype (the
  type is otherwise inferred from it). Without a matching provider above the
  context it throws a `TypeError` (`type 'Null' is not a subtype of type
  '_BlocProviderInherited<MyBloc>'`).
- The widget that builds the provider cannot find it with its own context:
  use a `Builder` or a child widget.
- Nothing rebuilds when the bloc changes (`of` registers no dependency):
  listen to what the bloc exposes (`StreamBuilder`, `ValueListenableBuilder`).
- `blocBuilder` runs once (in `initState`); a new `blocBuilder` given on a
  rebuild is ignored.
- Override `dispose()` to close the bloc's controllers and call
  `super.dispose()` (`@mustCallSuper`).

Agent skill:
[tekartik-app-flutter-bloc-provider](skills/tekartik-app-flutter-bloc-provider/SKILL.md).
