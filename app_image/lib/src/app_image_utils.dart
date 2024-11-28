import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:tekartik_common_utils/num_utils.dart';

/// Basic white image
final Future<ui.Image> image1x1WhiteAsync = () async {
  var recorder = ui.PictureRecorder();
  var canvas = ui.Canvas(recorder);
  canvas.drawColor(Colors.white, ui.BlendMode.src);
  var image = await recorder.endRecording().toImage(1, 1);
  return image;
}();

/// New colored image of a given size
Future<ui.Image> newUiImageColored(
    {Color? color, int? width, int? height}) async {
  width = (width ?? 1).boundedMin(1);
  height = (height ?? 1).boundedMin(1);
  var recorder = ui.PictureRecorder();
  var canvas = ui.Canvas(recorder);
  canvas.drawColor(Colors.white, ui.BlendMode.src);
  var image = await recorder.endRecording().toImage(width, height);
  return image;
}
