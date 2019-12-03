import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

class BehaviorSubjectBuilder<T> extends StatelessWidget {
  final BehaviorSubject<T> subject;
  final AsyncWidgetBuilder<T> builder;

  const BehaviorSubjectBuilder({Key key, this.subject, this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: builder,
      stream: subject,
      initialData: subject.value,
    );
  }
}
