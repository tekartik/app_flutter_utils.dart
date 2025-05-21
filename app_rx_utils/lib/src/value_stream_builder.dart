import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ValueStreamBuilder<T> extends StatelessWidget {
  final ValueStream<T> stream;
  final AsyncWidgetBuilder<T> builder;

  const ValueStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      builder: builder,
      stream: stream,
      initialData: stream.hasValue ? stream.value : null,
    );
  }
}
