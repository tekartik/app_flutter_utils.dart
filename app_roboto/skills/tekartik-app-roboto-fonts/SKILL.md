---
name: tekartik-app-roboto-fonts
description: >-
  Use when a Flutter app must ship the Roboto, Roboto Mono or Roboto Condensed
  fonts itself (offline, web, Linux/Windows desktop, consistent rendering)
  with tekartik_app_roboto: the robotoFontFamily, robotoMonoFontFamily and
  robotoCondensedFontFamily constants of
  package:tekartik_app_roboto/app_roboto.dart, and the
  packages/tekartik_app_roboto/fonts/... asset declarations to paste in the
  app pubspec.yaml flutter.fonts section (weight 100..900, style italic).
---

# Roboto fonts (tekartik_app_roboto)

`tekartik_app_roboto` is a font-only package: it carries the Roboto, Roboto
Mono and Roboto Condensed `.ttf` files (Apache 2.0, see the `LICENSE.txt`
next to each family) plus the three family name constants. The app declares
the faces it needs in its own `pubspec.yaml`, so nothing unused is bundled.

## Guidelines

* The package is not on pub.dev, depend on it from git:

  ```yaml
  dependencies:
    tekartik_app_roboto:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_roboto
      version: '>=0.1.0'
  ```

  It is a plain Dart package (no Flutter dependency): it only ships assets
  and constants.
* The package does **not** declare the fonts itself. Declare in the app's
  `pubspec.yaml`, under `flutter: fonts:`, only the families and weights the
  app uses; every asset path is
  `packages/tekartik_app_roboto/fonts/<Family>/<File>.ttf`.
* Files actually shipped (never reference another one, the build fails):
  * `fonts/Roboto/`: `Roboto-Thin.ttf` (100), `Roboto-Light.ttf` (300),
    `Roboto-Regular.ttf` (400), `Roboto-Medium.ttf` (500),
    `Roboto-Bold.ttf` (700), `Roboto-Black.ttf` (900).
  * `fonts/RobotoMono/`: `RobotoMono-Regular.ttf` (400),
    `RobotoMono-Bold.ttf` (700).
  * `fonts/RobotoCondensed/`: `RobotoCondensed-Light.ttf` (300),
    `RobotoCondensed-LightItalic.ttf` (300, italic),
    `RobotoCondensed-Regular.ttf` (400),
    `RobotoCondensed-Italic.ttf` (400, italic),
    `RobotoCondensed-Bold.ttf` (700),
    `RobotoCondensed-BoldItalic.ttf` (700, italic).
    There is no Condensed Thin, Medium or Black: the "all" snippet of the
    package README lists `RobotoCondensed-Black.ttf`, which does not exist.
* Use the constants instead of string literals, they are the exact family
  names used in the declarations: `robotoFontFamily` (`'Roboto'`),
  `robotoMonoFontFamily` (`'RobotoMono'`),
  `robotoCondensedFontFamily` (`'RobotoCondensed'`), from
  `package:tekartik_app_roboto/app_roboto.dart`. `robotoFont` is the old
  alias of `robotoFontFamily`, marked to be deprecated: do not use it in new
  code.
* Do **not** pass `package: 'tekartik_app_roboto'` to `TextStyle` /
  `ThemeData`: the family is declared by the app itself, so the plain family
  name resolves it. The `packages/...` prefix only appears in the asset
  paths.
* Declaring a family named `Roboto` replaces the platform Roboto everywhere
  the theme uses it. That is the point on Linux, Windows and the web (where
  Roboto is not installed) and for pixel-identical rendering across
  platforms; on Android it is redundant weight in the bundle.
* Declare each weight you use with its `weight:` value. A weight that is not
  declared is synthesized by faux-bolding the closest one, which looks wrong
  for `FontWeight.w300` or `w900`. Same for `style: italic` (Condensed only).
* `robotoMonoFontFamily` is the one to use for code, logs, hex dumps and
  aligned numbers; `robotoCondensedFontFamily` for dense tables and narrow
  labels.
* A font asset only reaches the bundle through the app's `pubspec.yaml`: a
  library package in between must not declare it, or the faces are bundled
  twice.

## Examples

### App pubspec.yaml declaration (regular + mono)

```yaml
flutter:
  fonts:
    - family: Roboto
      fonts:
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Light.ttf
          weight: 300
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Regular.ttf
          weight: 400
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Medium.ttf
          weight: 500
        - asset: packages/tekartik_app_roboto/fonts/Roboto/Roboto-Bold.ttf
          weight: 700
    - family: RobotoMono
      fonts:
        - asset: packages/tekartik_app_roboto/fonts/RobotoMono/RobotoMono-Regular.ttf
          weight: 400
        - asset: packages/tekartik_app_roboto/fonts/RobotoMono/RobotoMono-Bold.ttf
          weight: 700
    - family: RobotoCondensed
      fonts:
        - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Regular.ttf
          weight: 400
        - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Italic.ttf
          weight: 400
          style: italic
        - asset: packages/tekartik_app_roboto/fonts/RobotoCondensed/RobotoCondensed-Bold.ttf
          weight: 700
```

### Theme using the bundled Roboto

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_roboto/app_roboto.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roboto app',
      // No `package:` argument: the app declares the family itself.
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: robotoFontFamily,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: robotoFontFamily,
      ),
      home: const Scaffold(body: Center(child: Text('Hello'))),
    );
  }
}
```

### Monospace and condensed text styles

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_roboto/app_roboto.dart';

/// Logs, code, hex dumps: a declared weight only (400 or 700).
const codeTextStyle = TextStyle(
  fontFamily: robotoMonoFontFamily,
  fontSize: 13,
  height: 1.4,
);

/// Dense table header, Condensed ships 300/400/700 and their italics.
const tableHeaderTextStyle = TextStyle(
  fontFamily: robotoCondensedFontFamily,
  fontWeight: FontWeight.w700,
);

class CodeView extends StatelessWidget {
  final String text;

  const CodeView({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(text, style: codeTextStyle),
    );
  }
}
```

### Per-widget override of the app font

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_roboto/app_roboto.dart';

/// Applies Roboto Condensed to a subtree (a dense list, a table...).
class CondensedTheme extends StatelessWidget {
  final Widget child;

  const CondensedTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(
          fontFamily: robotoCondensedFontFamily,
        ),
      ),
      child: child,
    );
  }
}
```
