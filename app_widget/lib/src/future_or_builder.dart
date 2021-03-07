import 'dart:async';

import 'package:flutter/material.dart';

/// FutureOr Builder.
class FutureOrBuilder<T> extends StatelessWidget {
  /// The value.
  final FutureOr<T> futureOr;

  /// The builder.
  final AsyncWidgetBuilder<T> builder;

  /// FutureOr Builder.
  const FutureOrBuilder(
      {Key? key, required this.futureOr, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (futureOr is Future) {
      return FutureBuilder<T>(future: futureOr as Future<T>, builder: builder);
    }
    return Builder(
        builder: (context) => builder(context,
            AsyncSnapshot.withData(ConnectionState.done, futureOr as T)));
  }
}
