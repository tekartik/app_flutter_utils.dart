import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ValueStreamBuilder<T> extends StatelessWidget {
  final ValueStream<T> stream;
  final AsyncWidgetBuilder<T> builder;

  const ValueStreamBuilder({Key? key, required this.stream, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: builder,
      stream: stream,
      initialData: stream.value,
    );
  }
}
