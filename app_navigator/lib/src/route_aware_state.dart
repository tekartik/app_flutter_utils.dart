import 'package:flutter/material.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

import 'route_aware.dart';

abstract class RouteAwareWithPath {
  ContentPath get contentPath;
}

abstract class RouteAwareStatefulWidget extends StatefulWidget
    implements RouteAwareWithPath {
  @override
  final ContentPath contentPath;
  const RouteAwareStatefulWidget({super.key, required this.contentPath});

  @override
  RouteAwareWidgetState<RouteAwareStatefulWidget> createState();
}

/// Interface
abstract class RouteAwareWidgetState<T extends StatefulWidget>
    implements State<T> {
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

extension RouteAwareStatePrvExt<T extends StatefulWidget>
    on RouteAwareStateBase<T> {
  /// Current content path
  ContentPath? get contentPath => _contentPath;
}
