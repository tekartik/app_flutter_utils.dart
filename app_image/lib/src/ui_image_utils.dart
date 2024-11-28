import 'dart:ui' as ui;

/// Common extension
extension UiImageImageFlutterExt on ui.Image {
  /// Get the ui size
  ui.Size get size => ui.Size(width.toDouble(), height.toDouble());

  /// Get the ui rect
  ui.Rect get rect =>
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
}
