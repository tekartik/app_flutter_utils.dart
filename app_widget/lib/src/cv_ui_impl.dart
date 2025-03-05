import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';

/// View controller private implementation
class CvUiModelViewControllerImpl implements CvUiModelViewController {
  /// Expanded widget
  final _expanded = <Widget, bool>{};

  /// Default to true
  bool isWidgetExpanded(Widget widget) => _expanded[widget] ?? true;

  /// Set widget expanded
  bool setWidgetExpanded(Widget widget, bool value) {
    _expanded[widget] = value;
    return value;
  }

  /// toggle the value, true if expanded
  bool toggleWidget(Widget widget, [bool? value]) {
    var expanded = value ?? !isWidgetExpanded(widget);
    // print('toggleWidget $expanded');
    return setWidgetExpanded(widget, expanded);
  }
}
