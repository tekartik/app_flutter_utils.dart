import 'package:flutter/material.dart';

import 'route_aware.dart';

/// Base class for supporting onResume/onPause
abstract class RouteAwareState<T extends StatefulWidget> extends State<T>
    with RouteAware, RouteAwareMixin<T> {
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
