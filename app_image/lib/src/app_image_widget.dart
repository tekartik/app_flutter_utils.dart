import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tekartik_app_image_flutter/src/ui_image_utils.dart';
import 'package:tekartik_app_image_flutter/utils/ui_size_utils.dart';

/// Global
final uiImageHighQualityPaint = newImageHighQualityPaint();

/// New each time
Paint newImageHighQualityPaint() => Paint()
  ..filterQuality = ui.FilterQuality.high
  ..isAntiAlias = true;

/// Ui Image widget
class UiImage extends StatelessWidget {
  /// The image
  final ui.Image image;

  /// How it fits
  final BoxFit? fit;

  /// Constructor
  const UiImage({
    super.key,
    this.fit,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AppUiImagePainter(image));
  }
}

class _AppUiImagePainter extends CustomPainter {
  final ui.Image image;

  _AppUiImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    var src = image.rect;
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    var dstHeight = size.height;
    var ratio = size.height / image.height;
    var dstWidth = image.width * ratio;
    var srcRect = size.rect;
    canvas.clipRect(srcRect);
    canvas.drawImageRect(
      image,
      src,
      Rect.fromCenter(
          center: size.rect.center, width: dstWidth, height: dstHeight),
      uiImageHighQualityPaint,
    );
  }

  @override
  bool shouldRepaint(_AppUiImagePainter oldDelegate) {
    return image != oldDelegate.image;
  }
}
