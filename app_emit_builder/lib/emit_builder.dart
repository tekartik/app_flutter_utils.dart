import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tekartik_app_emit/emit.dart';

/// Very bad idea....
@Deprecated('Do not use')
class EmitFutureOrBuilder<T> extends StatefulWidget {
  final EmitFutureOr<T> futureOr;
  final AsyncWidgetBuilder<T> builder;

  const EmitFutureOrBuilder({
    super.key,
    required this.futureOr,
    required this.builder,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EmitFutureOrBuilderState<T> createState() => _EmitFutureOrBuilderState<T>();
}

// ignore: deprecated_member_use_from_same_package, deprecated_member_use
class _EmitFutureOrBuilderState<T> extends State<EmitFutureOrBuilder<T>> {
  EmitFutureOrSubscription<T>? subscription;

  @override
  Widget build(BuildContext context) {
    subscription?.cancel();
    var value = widget.futureOr.toFutureOr();
    if (value is Future) {
      var completer = Completer<T>.sync();
      subscription = widget.futureOr.listen(
        (value) {
          completer.complete(value);
        },
        onError: (Object error) {
          completer.completeError(error);
        },
      );
      return FutureBuilder<T>(
        future: completer.future,
        builder: widget.builder,
      );
    } else {
      return widget.builder(
        context,
        AsyncSnapshot<T>.withData(ConnectionState.done, value),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the fetch if needed
    subscription?.cancel();
  }
}
