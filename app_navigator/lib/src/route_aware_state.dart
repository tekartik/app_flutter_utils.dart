import 'package:flutter/material.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

import 'route_aware.dart';

/// Route aware with path
abstract class RouteAwareWithPath {
  /// Current content path
  ContentPath get contentPath;
}

/// Route aware stateful widget
abstract class RouteAwareStatefulWidget extends StatefulWidget
    implements RouteAwareWithPath {
  @override
  final ContentPath contentPath;

  /// Constructor
  const RouteAwareStatefulWidget({super.key, required this.contentPath});

  @override
  RouteAwareWidgetState<RouteAwareStatefulWidget> createState();
}

/// Interface
abstract class RouteAwareWidgetState<T extends StatefulWidget>
    implements State<T> {
  /// True if resumed
  bool get resumed;
}

/// Compate
typedef RouteAwareState<T extends StatefulWidget> = RouteAwareStateBase<T>;

/// Base class for supporting onResume/onPause
abstract class RouteAwareStateBase<T extends StatefulWidget> extends State<T>
    with RouteAware, RouteAwareMixin<T> {
  /// Current content path
  ContentPath? _contentPath;
  @override
  void didChangeDependencies() {
    routeAwareDidChangeDependencies();
    super.didChangeDependencies();
  }

  @override
  void onResume() {
    //print('onResume()');
    super.onResume();
  }

  @override
  void onPause() {
    //print('onPause()');
    super.onPause();
  }

  @override
  void dispose() {
    routeAwareDispose();
    super.dispose();
  }
}

/// Extension (private)
extension RouteAwareStatePrvExt<T extends StatefulWidget>
    on RouteAwareStateBase<T> {
  /// Current content path
  ContentPath? get contentPath => _contentPath;
}
