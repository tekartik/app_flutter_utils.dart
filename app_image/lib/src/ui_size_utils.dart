import 'dart:ui' as ui;

/// Common helpers
extension UiImageSizeFlutterExt on ui.Size {
  /// Scale a size
  ui.Size scale(double ratio) => ui.Size(width * ratio, height * ratio);

  /// Build a rectable from 0x0
  ui.Rect get rect => ui.Rect.fromLTWH(0, 0, width, height);
}
