import 'package:flutter/material.dart';

class TilePadding extends StatelessWidget {
  final Widget child;
  const TilePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}
