// Register the RouteObserver as a navigation observer.
import 'package:tekartik_app_navigator_flutter/src/import.dart';
import 'package:tekartik_app_navigator_flutter/src/route_aware_state.dart';

/// To add to the material app observers
RouteObserver<ModalRoute<void>> get routeAwareObserver =>
    routeAwareManager.routeAwareObserver;

class RouteAwareManager {
  final RouteObserver<ModalRoute<void>> routeAwareObserver =
      RouteObserver<ModalRoute<void>>();

  final popLock = Lock();
  var popPaths = <String>[];
}

final routeAwareManager = RouteAwareManager();

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
    // print('didPush');
    onResume();
  }

  @override
  void didPopNext() {
    if (widget is RouteAwareWithPath) {
      var needOnResume = true;
      var path = (widget as RouteAwareWithPath).contentPath;

      routeAwareManager.popLock.synchronized(() {
        // Do it after
        for (var poppedPath in routeAwareManager.popPaths) {
          if (path.matchesString(poppedPath)) {
            // print('didPopNext no resume ${path.toPathString()}');
            needOnResume = false;
            break;
          }
        }
      }).then((_) {
        if (needOnResume) {
          onResume();
        }
      });
    } else {
      onResume();
    }
    if (widget is RouteAwareWithPath) {}
    // print('didPopNext ${routeAwareManager.popPaths}');
  }
}
