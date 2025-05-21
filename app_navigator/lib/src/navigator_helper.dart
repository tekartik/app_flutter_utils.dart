import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_navigator_flutter/page_route.dart';

/// Navigator helper extension
extension TekartikNavigatorStateHelperExt on NavigatorState {
  /// Pop until a path is matched. Returns true if found.
  Future<T?> pushBuilder<T>({
    required WidgetBuilder builder,
    bool? noAnimation,
  }) async {
    if (noAnimation == true) {
      return await push(NoAnimationMaterialPageRoute<T>(builder: builder));
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return await push(CupertinoPageRoute<T>(builder: builder));
      default:
        return await push(MaterialPageRoute<T>(builder: builder));
    }
  }
}
