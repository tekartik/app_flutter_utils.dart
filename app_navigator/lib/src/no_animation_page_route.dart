import 'package:flutter/material.dart';

/// No animation material page route
class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  /// Constructor
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
