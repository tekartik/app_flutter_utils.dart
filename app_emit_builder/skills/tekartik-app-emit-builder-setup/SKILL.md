---
name: tekartik-app-emit-builder-setup
description: >-
  Use when a Flutter widget must display the value of a tekartik_app_emit
  EmitFutureOr / EmitFutureOrController with tekartik_app_emit_builder:
  EmitFutureOrBuilder (deprecated: synchronous first frame when the value is
  already available, FutureBuilder otherwise, cancels the controller on
  rebuild and dispose), how to replace it with FutureBuilder plus
  toFutureOr()/toFuture(), the emit_builder.dart import, EmitCancelException.
---

# EmitFutureOrBuilder (tekartik_app_emit_builder)

`tekartik_app_emit_builder` holds one widget, `EmitFutureOrBuilder<T>`, that
renders an `EmitFutureOr<T>` from `tekartik_app_emit`: a cancellable
completer whose value can be read synchronously once available. The widget is
`@Deprecated('Do not use')` because of how it cancels; this skill explains
what it does, when it is still acceptable and what to write instead.

## Guidelines

* Dependencies (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_emit_builder:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_emit_builder
    tekartik_app_emit:
      git:
        url: https://github.com/tekartik/app_common_utils.dart
        path: app_emit
  ```
  Import `package:tekartik_app_emit_builder/emit_builder.dart` for the widget
  and `package:tekartik_app_emit/emit.dart` for `EmitFutureOr`,
  `EmitFutureOrController`, `EmitFutureOrSubscription` and
  `EmitCancelException` (the builder library does not re-export them).
* Producer side (`tekartik_app_emit`): `var controller =
  EmitFutureOrController<T>()`, hand out `controller.futureOr`, then
  `controller.complete(value)` or `controller.completeError(error)`;
  `controller.close()` cancels it when still pending (`cancel(reason:)`
  completes the future with `EmitCancelException`). `isCompleted` and
  `isCancelled` tell the state. `EmitFutureOr.withValue(value)` builds an
  already completed one. Consumer side: `futureOr.toFutureOr()` is the value
  when available, a `Future<T>` otherwise; `futureOr.toFuture()` always a
  future; `futureOr.listen(onValue, onError:)` returns an
  `EmitFutureOrSubscription` (single listener) whose `cancel()` cancels the
  controller itself.
* `EmitFutureOrBuilder<T>(futureOr:, builder:)` (`builder` is a Flutter
  `AsyncWidgetBuilder<T>`): when `toFutureOr()` already holds a value the
  `builder` is called synchronously with
  `AsyncSnapshot.withData(ConnectionState.done, value)`, no loading frame;
  otherwise it subscribes and delegates to a `FutureBuilder<T>` (`waiting`,
  then `done` with data or error).
* Why deprecated: every `build` cancels the previous subscription and
  `dispose` cancels it too; since a subscription cancel cancels the
  controller, a rebuild of the builder (parent rebuild, hot reload) before the
  value arrived completes the shared controller with `EmitCancelException`
  and every other consumer of that `EmitFutureOr` gets the error. Also only
  one listener is supported.
* If you keep using it: give each builder its own controller that nothing
  else listens to, place it under parents that do not rebuild while pending
  (`const` subtrees), and add `// ignore: deprecated_member_use` (and
  `deprecated_member_use_from_same_package` inside the package) at the usage.
* Preferred replacement: in a `State`, read `toFutureOr()` once in
  `initState` to get an initial value, and use `FutureBuilder<T>(future:
  futureOr.toFuture(), initialData: initialValue)`. Same synchronous first
  frame, no cancellation side effect, works with several consumers.
* Widget tests: pump the widget with a pending controller, `expect` the
  placeholder, `controller.complete(value)`, `await tester.pump()`, expect
  the value (see the package test `test/emit_builder_test.dart`).

## Examples

### Using the deprecated builder with a dedicated controller

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_emit/emit.dart';
import 'package:tekartik_app_emit_builder/emit_builder.dart';

class GreetingPage extends StatefulWidget {
  const GreetingPage({super.key});

  @override
  State<GreetingPage> createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage> {
  // Owned by this state, nobody else listens to it.
  final _controller = EmitFutureOrController<String>();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!_controller.isCompleted) {
        _controller.complete('Hello');
      }
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: deprecated_member_use_from_same_package, deprecated_member_use
      body: EmitFutureOrBuilder<String>(
        futureOr: _controller.futureOr,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return Center(child: Text(snapshot.data ?? 'loading...'));
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: GreetingPage()));
}
```

### Replacement: FutureBuilder with a synchronous initial value

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_emit/emit.dart';

class EmitValueText extends StatefulWidget {
  final EmitFutureOr<String> futureOr;

  const EmitValueText({super.key, required this.futureOr});

  @override
  State<EmitValueText> createState() => _EmitValueTextState();
}

class _EmitValueTextState extends State<EmitValueText> {
  late Future<String> _future;
  String? _initial;

  @override
  void initState() {
    super.initState();
    var value = widget.futureOr.toFutureOr();
    if (value is String) {
      _initial = value; // already available: first frame shows it
    }
    _future = widget.futureOr.toFuture();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _future,
      initialData: _initial,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          var error = snapshot.error;
          if (error is EmitCancelException) {
            return const Text('cancelled');
          }
          return Text('Error: $error');
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return Text(snapshot.data!);
      },
    );
  }
}

void main() {
  // Immediate value: rendered synchronously, no spinner frame.
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: EmitValueText(futureOr: EmitFutureOr.withValue('ready')),
        ),
      ),
    ),
  );
}
```

### Widget test of the builder

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_emit/emit.dart';
import 'package:tekartik_app_emit_builder/emit_builder.dart';

void main() {
  testWidgets('EmitFutureOrBuilder', (tester) async {
    var controller = EmitFutureOrController<String>();
    await tester.pumpWidget(
      MaterialApp(
        // ignore: deprecated_member_use_from_same_package, deprecated_member_use
        home: EmitFutureOrBuilder<String>(
          futureOr: controller.futureOr,
          builder: (context, snapshot) => Text(snapshot.data ?? 'no data'),
        ),
      ),
    );
    expect(find.text('no data'), findsOneWidget);
    controller.complete('done');
    await tester.pump();
    expect(find.text('done'), findsOneWidget);
  });
}
```
