# tekartik_app_flutter_intl

Json based localization for a Flutter app, a minimal alternative to
`gen-l10n`: one json asset per locale (`assets/i18n/<locale>.json`) mapping a
key (the English text) to its translation, loaded at runtime. This package
adds the Flutter asset loader `loadLocalizationMap` to
[tekartik_app_intl](https://github.com/tekartik/app_common_utils.dart/tree/main/app_intl)
(lookup, `{{param}}` rendering, the generator of the json files), which it
re-exports.

## Getting started

Not on pub.dev, add it as a git dependency, and declare the assets folder
(the path is fixed):

```yaml
dependencies:
  tekartik_app_flutter_intl:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_intl

flutter:
  assets:
    - assets/i18n/
```

`assets/i18n/fr_FR.json`:

```json
{
  "Cancel": "Annuler",
  "Hello {{name}}": "Bonjour {{name}}"
}
```

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var english = await loadLocalizationMap(enUsTextLocale);
  var french = await loadLocalizationMap(frFrTextLocale);
  // A key with parameters is looked up without them: 'Hello '.
  var text = intlText(
    french,
    'Hello ',
    data: {'name': 'Bob'},
    defaultLocalizationMap: english,
  );
  runApp(Center(child: Text(text, textDirection: TextDirection.ltr)));
}
```

Complete app in [example/main.dart](example/main.dart).

## Platforms

Every Flutter platform (assets through `rootBundle`).

## What to use

- `loadLocalizationMap(textLocale, {package})`: reads
  `assets/i18n/<textLocale.name>.json` (`packages/<package>/assets/i18n/...`
  for assets shipped by a library package).
- `intlText(map, key, {data, defaultLocalizationMap})`: the translation,
  else the default map's, else `[key]`, with `{{name}}` replaced by `data`.
- `TextLocale` (`enUsTextLocale`, `frFrTextLocale`, `TextLocale('de_DE')`).
- The generator (`LocalizationProject`, `bin/generate_intl.dart`) is in
  tekartik_app_intl.

## Common pitfalls

- The file name is exactly `TextLocale.name` (`fr_FR.json`, not `fr.json`).
- A missing asset throws (a `FlutterError`): catch it for optional locales.
- A key with parameters is looked up by its "safe key", the text before
  `{{` (`'Hello '` for `"Hello {{name}}"`).
- A null value in `data` throws (`intlRender` force unwraps it): pass `''`.
- Loading is asynchronous: load the maps before `runApp` (or show nothing
  until loaded) to avoid a frame without text.

Agent skill:
[tekartik-app-flutter-intl-setup](skills/tekartik-app-flutter-intl-setup/SKILL.md).
