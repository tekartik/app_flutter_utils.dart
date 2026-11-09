# tekartik_app_flutter_common_utils

Small Flutter helpers: colors (a material swatch from one color, 8-bit
components, hex strings), an asset bundle that pure Dart code can depend on,
the asset list, and a pointer workaround for iOS 26.

## Getting started

Not on pub.dev, add it as a git dependency (with `material_ui`, the material
library published outside the Flutter SDK, which these helpers use):

```yaml
dependencies:
  material_ui: '>=1.5.0'
  tekartik_app_flutter_common_utils:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_common
```

A theme from a hex brand color (complete app in
[example/main.dart](example/main.dart)):

```dart
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_common_utils/color.dart';
import 'package:tekartik_app_flutter_common_utils/hex_color.dart';

final brandColor = HexColor.fromHex('#0d6efd');

ThemeData brandTheme() => ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: generateMaterialColor(brandColor),
  ),
);

/// Black or white text, readable on [background].
Color textColorOn(Color background) =>
    background.isDark ? Colors.white : Colors.black;
```

Platforms: every Flutter platform.

## Libraries

| Import | What |
|---|---|
| `color.dart` | `generateMaterialColor(color)` (swatch: tints 50-400, the color at 500, shades 600-900), `color.isDark`, `compatValue`/`compatRed`/`compatGreen`/`compatBlue`/`compatAlpha` (the 8-bit ints of the deprecated `Color.value`, `red`...), `tintColorCompat`, `shadeColorCompat` |
| `hex_color.dart` | `HexColor.fromHex('#rrggbb' or '#aarrggbb')` (`#` optional), `HexColor.fromHexOrNull(text)`, `color.toHex()` (`#aarrggbb`, `leadingHashSign:`, `noAlpha:`) |
| `asset/asset_bundle.dart` | `tkRootBundle` (Flutter's `rootBundle` as a `TkAssetBundle` of tekartik_app_common_utils), `TkAssetBundleFlutter(assetBundle)` |
| `asset/asset_utils.dart` | `getAssetList()`: every asset key of the app |
| `workaround.dart` | `setupWorkaroundIos26()`: ignores the pointer events at (0, 0) of iOS 26 ([flutter#177992](https://github.com/flutter/flutter/issues/177992)), no-op elsewhere; call it after `WidgetsFlutterBinding.ensureInitialized()` |
| `common_utils_import.dart` | `tekartik_common_utils/common_utils_import.dart` for Flutter code |

## Common pitfalls

- `package:flutter/material.dart` vs `package:material_ui`: `generateMaterialColor`
  returns material_ui's `MaterialColor`, which Flutter's own `ThemeData` and
  `ColorScheme` do not accept (compile error). Use `material_ui` in the app.
- `HexColor` is an extension: its parsers are static, `HexColor.fromHex(...)`,
  not `Color.fromHex(...)`.
- `fromHexOrNull` returns null for `null` and non hex text, but does not
  check the length: `'#abc'` (CSS shorthand) gives a transparent color, not
  `#aabbcc`.
- A `MaterialColor` (`Colors.orange`) is never `==` to a plain `Color` of the
  same value (the runtime types differ): compare `compatValue`.

Agent skill:
[tekartik-app-flutter-common-utils-setup](skills/tekartik-app-flutter-common-utils-setup/SKILL.md).
