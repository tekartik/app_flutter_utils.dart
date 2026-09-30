---
name: tekartik-app-image-flutter-ui-image
description: >-
  Use when a Flutter app needs a generated dart:ui Image without any asset (a
  solid color fill, a crossed placeholder for a missing picture) or dart:ui
  size, rect and paint helpers with tekartik_app_image_flutter:
  newUiImageColored and newUiImagePlaceholder from
  package:tekartik_app_image_flutter/utils/ui_image_generator.dart, the
  ui.Image size and rect getters of utils/ui_image_utils.dart, the ui.Size
  scale and rect helpers of utils/ui_size_utils.dart and
  newImageHighQualityPaint() from utils/ui_paint_utils.dart for drawImageRect
  scaling, thumbnails, CustomPainter and RawImage. Not an image codec:
  decoding, encoding and file formats are out of scope.
---

# dart:ui image helpers (tekartik_app_image_flutter)

Four tiny libraries around `dart:ui` `Image`, `Size`, `Rect` and `Paint`:
generate a solid or placeholder `ui.Image` without any asset, read an image
as a `Size` or a `Rect`, scale a `Size`, and get a `Paint` set up for high
quality image scaling. No decoding, no encoding, no file access: that is
`dart:ui` `instantiateImageCodec` or an image package.

```dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tekartik_app_image_flutter/utils/ui_image_generator.dart';

/// A 50x50 red crossed placeholder shown with RawImage.
Widget placeholderWidget() => FutureBuilder<ui.Image>(
  future: newUiImagePlaceholder(color: Colors.red, width: 50, height: 50),
  builder: (context, snapshot) {
    var image = snapshot.data;
    if (image == null) {
      return const SizedBox(width: 50, height: 50);
    }
    return RawImage(image: image);
  },
);
```

## Guidelines

* Dependency (git, not on pub.dev):

  ```yaml
  dependencies:
    tekartik_app_image_flutter:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_image
      version: '>=0.1.0'
  ```

* Four libraries, one concept each; never import `lib/src/`:
  * `package:tekartik_app_image_flutter/utils/ui_image_generator.dart`:
    `newUiImageColored({Color? color, int? width, int? height})` and
    `newUiImagePlaceholder({Color? color, int? width, int? height})`, both
    `Future<ui.Image>`.
  * `package:tekartik_app_image_flutter/utils/ui_image_utils.dart`:
    `UiImageImageFlutterExt` on `ui.Image`: `size` and `rect`
    (`Rect.fromLTWH(0, 0, width, height)`, the source rect of
    `drawImageRect`).
  * `package:tekartik_app_image_flutter/utils/ui_size_utils.dart`:
    `UiImageSizeFlutterExt` on `ui.Size`: `scale(double ratio)` and `rect`.
  * `package:tekartik_app_image_flutter/utils/ui_paint_utils.dart`:
    `newImageHighQualityPaint()`, a fresh `Paint` with `filterQuality` high
    and `isAntiAlias` true.

### Generating images

* Both generators draw with a `PictureRecorder` and call `Picture.toImage`:
  they need the Flutter engine. They work in the app and in `flutter test`
  (the test binding renders them), not in a plain `dart test`.
* `width` and `height` default to 1 and are clamped to at least 1: a 0 or
  negative dimension gives a 1 pixel image, no exception.
* `color` defaults to white. `newUiImageColored` fills the whole image
  (`drawColor` with `BlendMode.src`), so the alpha is kept:
  `Colors.transparent` gives a fully transparent image.
* `newUiImagePlaceholder` draws on a transparent background: a border in the
  color (a stroke of 8 centered on the edge, so 4 visible pixels) and the two
  diagonals (stroke 4). It reads as "missing image" at any size and shows how
  a `BoxFit` stretches it, which is what the example app uses it for.
* A `ui.Image` is a GPU resource: `dispose()` it when the widget or painter
  that owns it goes away, and never dispose an image still given to a
  `RawImage` or a `CustomPainter`. Generate once (in `initState`, or a cached
  `Future`), never in `build`.
* Show a `ui.Image` with `RawImage(image:, fit:, alignment:)`, not with
  `Image`: `Image` takes an `ImageProvider`, not a `ui.Image`.

### Size, rect and paint

* `image.rect` is the full source rect for `Canvas.drawImageRect`;
  `image.size.scale(ratio).rect` is the destination rect of the same image at
  another scale. Both rects start at 0x0: `shift` them for an offset.
* `Size.scale` multiplies both dimensions by one ratio, so it keeps the
  aspect ratio. For a fit, compute the ratio first
  (`min(dstWidth / image.width, dstHeight / image.height)`).
* Use `newImageHighQualityPaint()` for `drawImageRect` and `drawImage`
  whenever the image is scaled: the default `Paint` has `FilterQuality.none`
  and gives a pixelated result. It returns a new `Paint` each call, so
  setting `color`, `blendMode` or `style` on it is safe (the generators do).
* `Size` math stays in `double`; `toImage` wants `int` sizes: round
  (`round()`, `ceil()`) at the last step and clamp to at least 1.

## Examples

### Placeholder while a picture loads, disposed with the widget

```dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tekartik_app_image_flutter/utils/ui_image_generator.dart';

class PictureView extends StatefulWidget {
  /// The real picture, null while loading or missing.
  final ui.Image? picture;

  const PictureView({super.key, this.picture});

  @override
  State<PictureView> createState() => _PictureViewState();
}

class _PictureViewState extends State<PictureView> {
  // Generated once per widget, not in build.
  late final Future<ui.Image> _placeholder = newUiImagePlaceholder(
    color: Colors.grey,
    width: 160,
    height: 90,
  );

  @override
  void dispose() {
    // The widget owns the placeholder, not the picture.
    _placeholder.then((image) => image.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var picture = widget.picture;
    if (picture != null) {
      return RawImage(image: picture, fit: BoxFit.cover);
    }
    return FutureBuilder<ui.Image>(
      future: _placeholder,
      builder: (context, snapshot) => snapshot.hasData
          ? RawImage(image: snapshot.data, fit: BoxFit.contain)
          : const SizedBox.shrink(),
    );
  }
}
```

### Draw an image scaled to the available width (CustomPainter)

```dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tekartik_app_image_flutter/utils/ui_image_utils.dart';
import 'package:tekartik_app_image_flutter/utils/ui_paint_utils.dart';
import 'package:tekartik_app_image_flutter/utils/ui_size_utils.dart';

class FitWidthImagePainter extends CustomPainter {
  final ui.Image image;

  FitWidthImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Same ratio on both dimensions: the aspect ratio is kept.
    var ratio = size.width / image.width;
    var dst = image.size.scale(ratio).rect;
    canvas.drawImageRect(image, image.rect, dst, newImageHighQualityPaint());
  }

  @override
  bool shouldRepaint(FitWidthImagePainter oldDelegate) =>
      oldDelegate.image != image;
}

/// Sized by its parent, the image fills the width.
Widget fitWidthImage(ui.Image image) =>
    CustomPaint(painter: FitWidthImagePainter(image));
```

### Resize a ui.Image to a thumbnail that fits a box

```dart
import 'dart:math';
import 'dart:ui' as ui;

import 'package:tekartik_app_image_flutter/utils/ui_image_utils.dart';
import 'package:tekartik_app_image_flutter/utils/ui_paint_utils.dart';
import 'package:tekartik_app_image_flutter/utils/ui_size_utils.dart';

/// A new image, at most [maxWidth] x [maxHeight], same aspect ratio.
/// The caller owns (and disposes) both images.
Future<ui.Image> thumbnail(
  ui.Image image, {
  required int maxWidth,
  required int maxHeight,
}) async {
  var ratio = min(maxWidth / image.width, maxHeight / image.height);
  var size = image.size.scale(ratio);
  var width = max(1, size.width.round());
  var height = max(1, size.height.round());

  var recorder = ui.PictureRecorder();
  var canvas = ui.Canvas(recorder);
  var dst = ui.Size(width.toDouble(), height.toDouble()).rect;
  canvas.drawImageRect(image, image.rect, dst, newImageHighQualityPaint());
  return await recorder.endRecording().toImage(width, height);
}
```

### Test the generated pixels (flutter test)

```dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_image_flutter/utils/ui_image_generator.dart';
import 'package:tekartik_app_image_flutter/utils/ui_image_utils.dart';

void main() {
  test('colored image', () async {
    var image = await newUiImageColored(color: Colors.red, width: 4, height: 2);
    expect(image.size, const Size(4, 2));
    expect(image.rect, const Rect.fromLTWH(0, 0, 4, 2));

    var bytes = (await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    ))!.buffer.asUint8List();
    // First pixel, r g b a: Colors.red is 0xFFF44336.
    expect(bytes.sublist(0, 4), [244, 67, 54, 255]);
    image.dispose();
  });

  test('sizes are clamped to 1', () async {
    var image = await newUiImageColored(width: 0, height: -3);
    expect(image.size, const Size(1, 1));
    image.dispose();
  });
}
```

## Common mistakes

* `RawImage` shows nothing and the log asserts about a disposed image: the
  image was disposed while still displayed. Dispose in `State.dispose`, after
  the last frame that used it, and only images this widget created.
* Scaled images look pixelated or blurry: `drawImageRect` was called with a
  default `Paint`. Use `newImageHighQualityPaint()`.
* `The argument type 'Image' can't be assigned to 'ImageProvider'`: `Image`
  (the widget) was given a `ui.Image`. Use `RawImage`.
* `Image` is ambiguous: `dart:ui` and `package:flutter/material.dart` both
  export a type named `Image`. Import `dart:ui` as `ui` and write `ui.Image`.
* `The getter 'rect' isn't defined for the type 'Size'` (or `Image`): the
  extension library is not imported; import `utils/ui_size_utils.dart` (or
  `utils/ui_image_utils.dart`), the `src/` files are not exported.
* A generator hangs or throws in a `dart test` (no Flutter binding): the
  generators render with the engine, run them under `flutter test`.

## More

* Package README for the setup, CHANGELOG for the version history.
