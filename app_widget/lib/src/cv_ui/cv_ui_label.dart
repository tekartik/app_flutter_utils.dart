import 'package:flutter/material.dart';

class CvUiFieldLabel extends StatelessWidget {
  final String name;

  const CvUiFieldLabel({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(name, style: TextTheme.of(context).labelSmall);
  }
}

class CvUiListItemLabel extends StatelessWidget {
  final int index;

  const CvUiListItemLabel({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Text(
      'item $index',
      style: TextTheme.of(context).labelSmall
        ?..copyWith(fontStyle: FontStyle.italic),
    );
  }
}
