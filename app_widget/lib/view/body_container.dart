import 'package:flutter/material.dart';

class BodyContainer extends StatelessWidget {
  final Widget? child;
  final double width;

  const BodyContainer({super.key, this.child, this.width = 840});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(width: width, child: child),
    );
  }
}
