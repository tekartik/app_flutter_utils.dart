import 'package:flutter/material.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

/// Navigator extension
extension TekartikNavigatorStateExt on NavigatorState {
  /// Pop until a path is matched. Returns true if found.
  bool popUntilPath(ContentPath path) {
    var found = false;
    popUntil((route) {
      // print('popUntil($path) checking ${route.settings.name}');
      var matches =
          route.settings.name != null &&
          path.matchesString(route.settings.name!);
      found = found || matches;
      return matches;
    });
    return found;
  }
}

/// Navigator extension
extension TekartikNavigatorStatePrvExt on NavigatorState {
  /// Pop until a path is matched. Returns true if found.
  bool popUntilPath(ContentPath path) {
    var found = false;
    popUntil((route) {
      // print('popUntil($path) checking $route');
      var matches =
          route.settings.name != null &&
          path.matchesString(route.settings.name!);
      found = found || matches;
      return matches;
    });
    return found;
  }
}
