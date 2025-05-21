import 'package:flutter/widgets.dart';

import 'content_path.dart';

/// Router config for MaterialApp.router
class ContentRouterConfig extends RouterConfig<ContentPath> {
  /// Constructor
  ContentRouterConfig({
    required super.routerDelegate,
    super.routeInformationParser,
  });
}
