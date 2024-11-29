import 'dart:ui' as ui;

/// Global
final uiImageHighQualityPaint = newImageHighQualityPaint();

/// New each time
ui.Paint newImageHighQualityPaint() => ui.Paint()
  ..filterQuality = ui.FilterQuality.high
  ..isAntiAlias = true;
