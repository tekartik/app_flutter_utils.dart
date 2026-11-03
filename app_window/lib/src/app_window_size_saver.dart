import 'package:flutter/widgets.dart';

import 'app_window.dart';
import 'app_window_factory.dart';
import 'app_window_size_keeper.dart';

/// Saves the size of the app window while it is in the tree
/// ([AppWindowSizeKeeper.autoSave]), restored on the next launch by
/// [AppWindowSizeKeeper.restoreAppWindow]. Nothing happens where there is no
/// app window (the web, mobile, `flutter test`).
class AppWindowSizeSaver extends StatefulWidget {
  /// Where the size goes.
  final AppWindowSizeKeeper keeper;

  /// The window, `appWindowCurrent()` (disposed with this widget) when null.
  final AppWindow? window;

  /// The app.
  final Widget child;

  /// Saves the window size with [keeper] while [child] is shown.
  const AppWindowSizeSaver({
    super.key,
    required this.keeper,
    this.window,
    required this.child,
  });

  @override
  State<AppWindowSizeSaver> createState() => _AppWindowSizeSaverState();
}

class _AppWindowSizeSaverState extends State<AppWindowSizeSaver> {
  AppWindow? _ownWindow;
  VoidCallback? _stop;

  @override
  void initState() {
    super.initState();
    var window = widget.window ?? (_ownWindow = appWindowCurrent());
    if (window != null) {
      _stop = widget.keeper.autoSave(window);
    }
  }

  @override
  void dispose() {
    _stop?.call();
    _ownWindow?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
