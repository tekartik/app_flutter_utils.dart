import 'package:flutter/cupertino.dart';

class BodyHPadding extends StatelessWidget {
  final Widget? child;
  const BodyHPadding({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}
