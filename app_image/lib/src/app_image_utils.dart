import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:tekartik_app_image_flutter/utils/ui_size_utils.dart';
import 'package:tekartik_common_utils/num_utils.dart';

import 'ui_paint_utils.dart';

/// Basic white image
final Future<ui.Image> image1x1WhiteAsync = () async {
  var recorder = ui.PictureRecorder();
  var canvas = ui.Canvas(recorder);
  canvas.drawColor(Colors.white, ui.BlendMode.src);
  var image = await recorder.endRecording().toImage(1, 1);
  return image;
}();

/// New colored image of a given size
Future<ui.Image> newUiImageColored({
  Color? color,
  int? width,
  int? height,
}) async {
  width = (width ?? 1).boundedMin(1);
  height = (height ?? 1).boundedMin(1);
  var recorder = ui.PictureRecorder();
  var canvas = ui.Canvas(recorder);
  canvas.drawColor(color ?? Colors.white, ui.BlendMode.src);
  var image = await recorder.endRecording().toImage(width, height);
  return image;
}

/// New colored image of a given size
Future<ui.Image> newUiImagePlaceholder({
  Color? color,
  int? width,
  int? height,
}) async {
  color ??= Colors.white;
  width = (width ?? 1).boundedMin(1);
  height = (height ?? 1).boundedMin(1);
  var recorder = ui.PictureRecorder();
  var canvas = ui.Canvas(recorder);
  var paint = newImageHighQualityPaint()
    ..color = color
    ..strokeWidth = 8
    ..style = PaintingStyle.stroke;
  var rect = ui.Size(width.toDouble(), height.toDouble()).rect;
  canvas.drawRect(rect, paint);
  paint = newImageHighQualityPaint()
    ..color = color
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke;
  canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
  canvas.drawLine(rect.topRight, rect.bottomLeft, paint);

  var image = await recorder.endRecording().toImage(width, height);
  return image;
}
