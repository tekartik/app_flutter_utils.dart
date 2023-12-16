import 'package:flutter/widgets.dart';

typedef WillPopCallbackCompat = Future<bool> Function();

/// Basic compat layer
class WillPopScopeCompat extends StatelessWidget {
  final Widget child;

  const WillPopScopeCompat({super.key, required this.child, this.onWillPop});

  /// Called to veto attempts by the user to dismiss the enclosing [ModalRoute].
  ///
  /// If the callback returns a Future that resolves to false, the enclosing
  /// route will not be popped.
  final WillPopCallbackCompat? onWillPop;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (invoked) async {
        if (invoked) {
          return;
        }
        var willPop = (await onWillPop?.call() ?? false);
        if (willPop) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: child,
    );
  }
}
