# tekartik_app_emit_builder

`EmitFutureOrBuilder`, a Flutter widget showing the value of an
`EmitFutureOr` of [tekartik_app_emit](https://github.com/tekartik/app_common_utils.dart/tree/master/app_emit)
(a cancellable completer whose value can be read synchronously once
available): the value at once when it is there, a `FutureBuilder` before.

**Deprecated**: prefer a `FutureBuilder` (see [Replacement](#replacement)).

## Getting started

Not on pub.dev, add both packages as git dependencies:

```yaml
dependencies:
  tekartik_app_emit:
    git:
      url: https://github.com/tekartik/app_common_utils.dart
      path: app_emit
  tekartik_app_emit_builder:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_emit_builder
```

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_emit/emit.dart';
import 'package:tekartik_app_emit_builder/emit_builder.dart';

/// [futureOr] must have its own controller, nothing else listening to it.
Widget greeting(EmitFutureOr<String> futureOr) =>
    // ignore: deprecated_member_use
    EmitFutureOrBuilder<String>(
      futureOr: futureOr,
      builder: (context, snapshot) => Text(snapshot.data ?? 'loading...'),
    );
```

Platforms: every Flutter platform (plain widgets, no material).

## Why deprecated

Each `build` (and `dispose`) cancels the previous subscription, and cancelling
a subscription cancels the controller itself: a rebuild while the value is
pending completes the shared `EmitFutureOrController` with an
`EmitCancelException`, and every other consumer gets that error. If you keep
it, give it a controller of its own and a parent that does not rebuild while
pending.

## Replacement

Read the value once, then a `FutureBuilder` with it as initial data: same
synchronous first frame, nothing cancelled, any number of consumers.

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_emit/emit.dart';

class EmitValueText extends StatefulWidget {
  final EmitFutureOr<String> futureOr;

  const EmitValueText({super.key, required this.futureOr});

  @override
  State<EmitValueText> createState() => _EmitValueTextState();
}

class _EmitValueTextState extends State<EmitValueText> {
  late final Future<String> _future = widget.futureOr.toFuture();
  late final String? _initial = switch (widget.futureOr.toFutureOr()) {
    String value => value, // already available: shown in the first frame
    _ => null,
  };

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: _future,
    initialData: _initial,
    builder: (context, snapshot) => Text(
      snapshot.hasError ? 'Error' : snapshot.data ?? 'loading...',
    ),
  );
}
```

Agent skill:
[tekartik-app-emit-builder-setup](skills/tekartik-app-emit-builder-setup/SKILL.md).
