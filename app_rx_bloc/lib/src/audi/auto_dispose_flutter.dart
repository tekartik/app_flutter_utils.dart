import 'package:flutter/widgets.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_bloc.dart';

/// Auto dispose extension for rx
extension AutoDisposeValueNotifierExtension on AutoDispose {
  /// Add a TextEditingController to the auto dispose list
  TextEditingController audiAddTextEditingController(
    TextEditingController controller,
  ) {
    return audiAdd(controller, controller.dispose);
  }

  /// Add a ValueNotifier to the auto dispose list
  ValueNotifier<T> audiAddValueNotifier<T>(ValueNotifier<T> valueNotifier) {
    return audiAdd(valueNotifier, valueNotifier.dispose);
  }
}
