// Register the RouteObserver as a navigation observer.
import 'package:flutter/material.dart';

/// To add to the material app observers
final RouteObserver<ModalRoute<void>> routeAwareObserver =
    RouteObserver<ModalRoute<void>>();

/// Use it along with RouteAware mixin
///
/// ```
/// class _StartScreenState extends State<MyScreen>
///   with RouteAware, RouteAwareMixin<MyScreen> {}
/// ```
mixin RouteAwareMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  bool get resumed => _resumed;
  var _resumed = false;
  void routeAwareDidChangeDependencies() {
    routeAwareObserver.subscribe(this, ModalRoute.of(context)!);
  }

  void routeAwareDispose() {
    routeAwareObserver.unsubscribe(this);
  }

  @override
  void didPushNext() {
    onPause();
  }

  @override
  void didPop() {
    onPause();
  }

  @mustCallSuper
  void onPause() {
    _resumed = false;
  }

  @mustCallSuper
  void onResume() {
    _resumed = true;
  }

  @override
  void didPush() {
    onResume();
  }

  @override
  void didPopNext() {
    onResume();
  }
}
