# tekartik_app_image_flutter

Small `dart:ui` helpers for Flutter: generate a `ui.Image` without any asset
(a solid color, a crossed placeholder), read an image as a `Size`/`Rect`,
scale a `Size`, and get a `Paint` set up for high quality image scaling. Not
an image codec: no decoding, encoding or file access.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_image_flutter:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_image
```

A red crossed placeholder shown with `RawImage`:

```dart
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:tekartik_app_image_flutter/utils/ui_image_generator.dart';

// Generate it once (initState, a field), not in build.
final Future<ui.Image> placeholder = newUiImagePlaceholder(
  color: const Color(0xFFF44336),
  width: 160,
  height: 90,
);

Widget placeholderView() => FutureBuilder<ui.Image>(
  future: placeholder,
  builder: (context, snapshot) => snapshot.hasData
      ? RawImage(image: snapshot.data, fit: BoxFit.contain)
      : const SizedBox(width: 160, height: 90),
);
```

Platforms: every Flutter platform. The generators render with the Flutter
engine: they run in an app and in `flutter test`, not in a plain `dart test`
(`dart:ui` is not available there).

## Libraries

| Import (`package:tekartik_app_image_flutter/...`) | Gives |
|---|---|
| `utils/ui_image_generator.dart` | `newUiImageColored`, `newUiImagePlaceholder` (`Future<ui.Image>`; width and height default to 1, clamped to at least 1; color defaults to white) |
| `utils/ui_image_utils.dart` | `ui.Image` `size` and `rect` (the source rect of `drawImageRect`) |
| `utils/ui_size_utils.dart` | `ui.Size` `scale(ratio)` and `rect` |
| `utils/ui_paint_utils.dart` | `newImageHighQualityPaint()`: a new `Paint` with `FilterQuality.high`, anti-aliased |

## Common pitfalls

- A generated `ui.Image` is a GPU resource: `dispose()` it when its owner
  goes away, never while a `RawImage` still shows it.
- `Image` (the widget) takes an `ImageProvider`: show a `ui.Image` with
  `RawImage`.
- A scaled `drawImageRect` with a default `Paint` looks pixelated: use
  `newImageHighQualityPaint()`.

More in the package skill (`skills/tekartik-app-image-flutter-ui-image`).
