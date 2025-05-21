// Register the RouteObserver as a navigation observer.
import 'package:tekartik_app_navigator_flutter/src/import.dart';
import 'package:tekartik_app_navigator_flutter/src/route_aware_state.dart';

/// To add to the material app observers
RouteObserver<ModalRoute<void>> get routeAwareObserver =>
    routeAwareManager.routeAwareObserver;

/// To add to the material app observers
class RouteAwareManager {
  /// Route observer
  final RouteObserver<ModalRoute<void>> routeAwareObserver =
      RouteObserver<ModalRoute<void>>();

  @protected
  /// Pop lock
  final _popLock = Lock();

  final _popPaths = <String>[];

  var _popTransient = false;
}

/// Private extension
extension RouteAwareManagerPrvExt on RouteAwareManager {
  /// Pop lock
  Lock get popLock => _popLock;

  /// Only valid during pop
  List<String> get popPaths => _popPaths;

  /// Set to true to ignore the next pop
  bool get popTransient => _popTransient;
  set popTransient(bool value) {
    _popTransient = value;
  }
}

/// Route aware manager
final routeAwareManager = RouteAwareManager();

/// Use it along with RouteAware mixin
///
/// ```
/// class _StartScreenState extends State<MyScreen>
///   with RouteAware, RouteAwareMixin<MyScreen> {}
/// ```
mixin RouteAwareMixin<T extends StatefulWidget> on State<T>
    implements RouteAware, RouteAwareWidgetState<T> {
  @override
  bool get resumed => _resumed;
  var _resumed = false;

  /// Route aware did change dependencies
  void routeAwareDidChangeDependencies() {
    routeAwareObserver.subscribe(this, ModalRoute.of(context)!);
  }

  /// Route aware dispose
  void routeAwareDispose() {
    routeAwareObserver.unsubscribe(this);
  }

  @override
  void didPushNext() {
    _onPauseIfResumed();
  }

  void _onPauseIfResumed() {
    if (_resumed) {
      onPause();
    }
  }

  void _onResumeIfPaused() {
    if (!_resumed) {
      onResume();
    }
  }

  @override
  void didPop() {
    _onPauseIfResumed();
  }

  /// On pause
  @mustCallSuper
  void onPause() {
    _resumed = false;
  }

  /// On resume
  @mustCallSuper
  void onResume() {
    _resumed = true;
  }

  /// did Push
  @override
  void didPush() {
    // print('didPush');
    _onResumeIfPaused();
  }

  @override
  void didPopNext() {
    if (routeAwareManager.popTransient) {
      return;
    }
    if (widget is RouteAwareWithPath) {
      var needOnResume = true;
      var path = (widget as RouteAwareWithPath).contentPath;

      routeAwareManager.popLock
          .synchronized(() {
            // Do it after
            for (var poppedPath in routeAwareManager.popPaths) {
              if (path.matchesString(poppedPath)) {
                // print('didPopNext no resume ${path.toPathString()}');
                needOnResume = false;
                break;
              }
            }
          })
          .then((_) {
            if (needOnResume) {
              _onResumeIfPaused();
            }
          });
    } else {
      _onResumeIfPaused();
    }
    if (widget is RouteAwareWithPath) {}
    // print('didPopNext ${routeAwareManager.popPaths}');
  }
}
