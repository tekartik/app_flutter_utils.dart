import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class BehaviorSubjectBuilder<T> extends StatelessWidget {
  final BehaviorSubject<T> subject;
  final AsyncWidgetBuilder<T> builder;

  const BehaviorSubjectBuilder(
      {Key? key, required this.subject, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      builder: builder,
      stream: subject,
      initialData: subject.hasValue ? subject.value : null,
    );
  }
}
