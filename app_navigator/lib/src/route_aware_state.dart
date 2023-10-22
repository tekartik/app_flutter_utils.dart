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
  RouteAwareState<RouteAwareStatefulWidget> createState();
}

/// Base class for supporting onResume/onPause
abstract class RouteAwareState<T extends StatefulWidget> extends State<T>
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
    on RouteAwareState<T> {
  /// Current content path
  ContentPath? get contentPath => _contentPath;
}
