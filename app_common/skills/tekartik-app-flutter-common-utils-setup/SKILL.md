---
name: tekartik-app-flutter-common-utils-setup
description: >-
  Use when Flutter code needs the small Tekartik Flutter helpers of
  tekartik_app_flutter_common_utils: color helpers (generateMaterialColor,
  generateMaterialColorCompat, tintColorCompat, shadeColorCompat,
  Color.isDark, Color.compatValue/compatRed/compatGreen/compatBlue/compatAlpha
  replacing the deprecated Color.value/red/green/blue/alpha,
  HexColor.fromHex/fromHexOrNull/toHex), assets (tkRootBundle,
  TkAssetBundleFlutter, TkAssetBundle, getAssetList), the iOS 26 pointer
  workaround (setupWorkaroundIos26) and the common_utils_import.dart re-export
  of tekartik_common_utils for Flutter code.
---

# Flutter common utilities (tekartik_app_flutter_common_utils)

A grab bag of Flutter-side helpers that complement the pure Dart
`tekartik_app_common_utils` and `tekartik_common_utils`: colors (material
swatch generation, 8-bit component access, hex parsing), an abstract asset
bundle backed by `rootBundle`, the asset manifest listing and a pointer-event
workaround for iOS 26.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_common_utils:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_common
  ```
  There is no umbrella import; pick the library you need:
  `package:tekartik_app_flutter_common_utils/color.dart`, `hex_color.dart`,
  `asset/asset_bundle.dart`, `asset/asset_utils.dart`, `workaround.dart`,
  `common_utils_import.dart`.

### Colors (`color.dart`, `hex_color.dart`)

* Flutter's `Color.value`, `red`, `green`, `blue` and `alpha` are deprecated
  (components are now doubles). `TekartikColorFlutterCompatExt` (in
  `color.dart`) gives the 8-bit integers back: `color.compatValue` (32-bit
  ARGB), `compatRed`, `compatGreen`, `compatBlue`, `compatAlpha`. Use them for
  persistence, hashing and hex output.
* `generateMaterialColor(color)` (same as `generateMaterialColorCompat`)
  builds a `MaterialColor` swatch from one seed: 50-400 are tints toward
  white, 500 is the seed, 600-900 are shades toward black. Feed it to
  `ColorScheme.fromSwatch(primarySwatch:)` or index it (`swatch[100]`). The
  building blocks are exported too: `tintColorCompat(color, factor)`,
  `shadeColorCompat(color, factor)` (factor 0..1, result always opaque) and
  the int variants `tintValueCompat(value, factor)`,
  `shadeValueCompat(value, factor)`.
* `color.isDark` (`TekartikColorFlutterExt`): luminance
  `0.299 r + 0.587 g + 0.114 b` below `0.5` on 0..1 components; use it to
  choose a contrasting foreground. `Colors.blue.isDark` is `true`,
  `Colors.yellow`-like colors are not.
* `HexColor` is an extension on `Color` whose parsers are static: call
  `HexColor.fromHex('#0d6efd')`, not `Color.fromHex`. Accepted forms:
  `rrggbb`, `#rrggbb` (alpha `ff` is added), `aarrggbb`, `#aarrggbb`.
  `HexColor.fromHexOrNull(text)` returns `null` for `null`, empty or
  unparsable input; `fromHex` throws on those. `color.toHex()` returns
  `'#aarrggbb'` in lowercase; `toHex(leadingHashSign: false)` drops the `#`,
  `toHex(noAlpha: true)` gives `'#rrggbb'`. `toHex()` output round-trips
  through `fromHex`.

### Assets (`asset/asset_bundle.dart`, `asset/asset_utils.dart`)

* `tkRootBundle` is a `TkAssetBundle` wrapping Flutter's `rootBundle`:
  `loadString(key)`, `loadByteData(key)` and `loadBytes(key)`
  (`Uint8List`). Keys are the pubspec asset paths, and
  `packages/<package>/<path>` for assets of another package. The abstract
  `TkAssetBundle` type is not re-exported: import it from
  `package:tekartik_app_common_utils/asset/asset_bundle.dart` (a dependency
  of this package) wherever you name the type.
* Write loaders against `TkAssetBundle` in pure Dart code and pass
  `tkRootBundle` from the app: the Dart code stays Flutter-free and is tested
  with `TkAssetBundleMemory` (`setString`, `setBytes`) from
  `tekartik_app_common_utils`. `TkAssetBundleFlutter(assetBundle)` wraps any
  other `AssetBundle` (for example `DefaultAssetBundle.of(context)`).
  `tkRootBundle` is a mutable top-level variable, tests may replace it.
* `getAssetList()` returns every key of the built `AssetManifest` (own and
  package assets). Use it to discover files under a folder
  (`where((k) => k.startsWith('assets/songs/'))`) instead of hardcoding
  names. It needs an initialized binding (`WidgetsFlutterBinding` or
  `TestWidgetsFlutterBinding.ensureInitialized()`).

### Workaround and imports

* `setupWorkaroundIos26()` (`workaround.dart`) installs a global pointer
  route that cancels pointer events at `Offset.zero` (Flutter issue 177992 on
  iOS 26). It is a no-op unless `!kIsWeb && Platform.isIOS`, idempotent, and
  safe to call on every platform. Call it once in `main()` after
  `WidgetsFlutterBinding.ensureInitialized()` (it uses
  `GestureBinding.instance`), before `runApp`.
* `common_utils_import.dart` re-exports
  `package:tekartik_common_utils/common_utils_import.dart` (`dart:async`,
  `dart:collection`, `dart:convert`, `meta`, `synchronized`, `devPrint`,
  `jsonPretty`, `parseBool`, ...) minus `format0To1AsPercent` and
  `formatTimestampMs`, which would clash in Flutter code. Import those two
  from `package:tekartik_common_utils/log_utils.dart` if needed.
* Tests run with `flutter test`; the color helpers are pure functions.

## Examples

### Theme from a hex brand color

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_utils/color.dart';
import 'package:tekartik_app_flutter_common_utils/hex_color.dart';

final brandColor = HexColor.fromHex('#0d6efd');
final brandSwatch = generateMaterialColor(brandColor);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: brandSwatch),
      ),
      home: Scaffold(
        backgroundColor: brandSwatch[100],
        body: Center(
          child: Container(
            color: brandColor,
            padding: const EdgeInsets.all(16),
            child: Text(
              brandColor.toHex(noAlpha: true),
              style: TextStyle(
                color: brandColor.isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
```

### Persist a color as int components or hex

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_utils/color.dart';
import 'package:tekartik_app_flutter_common_utils/hex_color.dart';

Map<String, Object?> colorToJson(Color color) => {
  'argb': color.compatValue,
  'hex': color.toHex(),
  'rgb': [color.compatRed, color.compatGreen, color.compatBlue],
  'alpha': color.compatAlpha,
};

Color? colorFromJson(Map<String, Object?> map) {
  var color = HexColor.fromHexOrNull(map['hex'] as String?);
  if (color == null && map['argb'] is int) {
    color = Color(map['argb'] as int);
  }
  return color;
}

void main() {
  var json = colorToJson(Colors.orange);
  print(json); // {argb: 4294940672, hex: #ffff9800, rgb: [255, 152, 0], ...}
  print(colorFromJson(json) == Colors.orange); // true
}
```

### Load assets through the abstract bundle and list them

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_common_utils/asset/asset_bundle.dart'
    show TkAssetBundle;
import 'package:tekartik_app_flutter_common_utils/asset/asset_bundle.dart';
import 'package:tekartik_app_flutter_common_utils/asset/asset_utils.dart';
import 'package:tekartik_app_flutter_common_utils/common_utils_import.dart';

/// Pure Dart: only depends on the abstract TkAssetBundle.
class SongRepository {
  final TkAssetBundle bundle;

  SongRepository(this.bundle);

  Future<Map<String, Object?>> loadSong(String key) async =>
      jsonDecode(await bundle.loadString(key)) as Map<String, Object?>;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var songKeys = (await getAssetList()).where(
    (key) => key.startsWith('assets/songs/') && key.endsWith('.json'),
  );
  var repository = SongRepository(tkRootBundle);
  for (var key in songKeys) {
    devPrint(jsonPretty(await repository.loadSong(key)));
  }
}
```

### Unit test the loader with a memory bundle (no Flutter binding)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_common_utils/asset/asset_bundle.dart';

Future<String> readGreeting(TkAssetBundle bundle) =>
    bundle.loadString('assets/greeting.txt');

void main() {
  test('readGreeting', () async {
    var bundle = TkAssetBundleMemory()
      ..setString('assets/greeting.txt', 'hello');
    expect(await readGreeting(bundle), 'hello');
  });
}
```

### iOS 26 pointer workaround at startup

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_utils/workaround.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupWorkaroundIos26(); // no-op except on iOS
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Hi')))));
}
```
