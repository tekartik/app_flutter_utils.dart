---
name: tekartik-app-flutter-intl-setup
description: >-
  Use when localizing a Flutter app with json asset files instead of arb/gen-l10n
  through tekartik_app_flutter_intl: the
  package:tekartik_app_flutter_intl/intl.dart import,
  loadLocalizationMap(textLocale, package:) reading assets/i18n/<locale>.json
  from rootBundle, TextLocale, enUsTextLocale, frFrTextLocale, enUsLocaleName,
  frFrLocaleName, intlText, intlRender with {{param}} placeholders,
  intlSafeKey, intlSafeLocalizationMap, intlDecodeLocalizationMap, and wiring
  it into a LocalizationsDelegate / Localizations.of.
---

# Json based localization for a Flutter app (tekartik_app_flutter_intl)

A minimal alternative to `gen-l10n`: each locale is one json asset mapping
the English source text to its translation, loaded at runtime from
`assets/i18n/`. This package adds the Flutter asset loader on top of
`tekartik_app_intl`.

## Guidelines

* Dependency (git, not on pub.dev), plus the assets declaration - the loader
  hardcodes the `assets/i18n/` folder:
  ```yaml
  dependencies:
    tekartik_app_flutter_intl:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_intl
      version: '>=0.1.0'

  flutter:
    assets:
      - assets/i18n/
  ```
* One public library: `package:tekartik_app_flutter_intl/intl.dart`. It
  re-exports `package:tekartik_app_intl/intl.dart` (`intlText`,
  `intlRender`, `intlSafeKey`, `intlSafeLocalizationMap`,
  `intlDecodeLocalizationMap`, `TextLocale`, `enUsTextLocale`,
  `frFrTextLocale`, `enUsLocaleName`, `frFrLocaleName`, `enLanguageName`,
  `frLanguageName`, `usCountryCode`, `frCountryCode`) and adds exactly one
  function:
  `Future<Map<String, String>> loadLocalizationMap(TextLocale textLocale,
  {String? package})`.
* `loadLocalizationMap` reads `assets/i18n/<locale name>.json` through
  `rootBundle` and returns the decoded, "safe" map. `package: 'my_pkg'`
  prefixes the path with `packages/my_pkg/`, which is what you need when the
  json assets ship inside a library package rather than the runner app. It
  throws (a `FlutterError`) when the asset is missing, so wrap the
  non-default locales in a try/catch.
* File layout: one file per locale, named after `TextLocale.name`, e.g.
  `assets/i18n/en_US.json` and `assets/i18n/fr_FR.json`. Ready made locales:
  `enUsTextLocale` (`en_US`) and `frFrTextLocale` (`fr_FR`); build any other
  with `TextLocale('de_DE')` or `TextLocale(locale.toString())` from a
  Flutter `Locale`.
* Keys are the English source text, values the translation. When a text has
  parameters, write them as `{{name}}` in the value; `intlSafeKey` truncates
  a key at its first `{{` (when a matching `}}` follows), and
  `intlSafeLocalizationMap` / `intlDecodeLocalizationMap` apply that to the
  whole map, so `"Hello {{name}}"` is looked up as `"Hello "`. Keep the same
  key spelling everywhere.
* Lookup: `intlText(localizationMap, key, data: {'name': 'Bob'},
  defaultLocalizationMap: enUsMap)` returns the translation, falls back to
  the default map, and finally to `'[$key]'` so a missing key is visible in
  the UI rather than crashing. `intlRender(template, data:)` does only the
  `{{name}}` substitution on an already resolved template.
* `data` values must not be null: `intlRender` force-unwraps them. Pass
  `''` rather than `null`.
* Always load the default (English) map and keep it as
  `defaultLocalizationMap`, then overlay the user's locale; a partially
  translated file then degrades gracefully.
* Wiring: implement a `LocalizationsDelegate<AppLocalizations>` whose `load`
  calls `loadLocalizationMap`, register it in
  `MaterialApp(localizationsDelegates: [...], supportedLocales: [...])` next
  to `GlobalMaterialLocalizations.delegate` (from `flutter_localizations`),
  and read it with `Localizations.of<AppLocalizations>(context,
  AppLocalizations)`. Return a `SynchronousFuture` from `load` to avoid a
  frame without text.
* Testing: `intlDecodeLocalizationMap`, `intlText`, `intlSafeKey` and
  `intlRender` are pure and unit testable without a device.
  `loadLocalizationMap` needs `TestWidgetsFlutterBinding.ensureInitialized()`
  because it hits `rootBundle`.
* Authoring/maintenance of the json files (sorting keys, extracting new
  texts) is done by `LocalizationProject` and the scripts in
  `package:tekartik_app_intl` (`build_intl.dart`, `bin/generate_intl.dart`),
  not by this package.

## Examples

### Load a locale and render texts

```dart
import 'package:tekartik_app_flutter_intl/intl.dart';

Future<void> main() async {
  // assets/i18n/en_US.json and assets/i18n/fr_FR.json
  var defaultMap = await loadLocalizationMap(enUsTextLocale);
  var map = await loadLocalizationMap(frFrTextLocale);

  print(intlText(map, 'Cancel', defaultLocalizationMap: defaultMap));
  print(
    intlText(
      map,
      'Hello ',
      data: {'name': 'Bob'},
      defaultLocalizationMap: defaultMap,
    ),
  );
  // Missing keys render as [key] instead of throwing.
  print(intlText(map, 'Unknown key'));
}
```

### A LocalizationsDelegate, wired into MaterialApp

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_intl/intl.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> map;
  final Map<String, String> defaultMap;

  AppLocalizations(this.locale, this.map, this.defaultMap);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  /// Translate [key], substituting {{param}} placeholders with [data].
  String t(String key, [Map<String, String>? data]) =>
      intlText(map, key, data: data, defaultLocalizationMap: defaultMap);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  static const supportedLocales = [Locale('en', 'US'), Locale('fr', 'FR')];

  @override
  bool isSupported(Locale locale) => supportedLocales
      .map((locale) => locale.languageCode)
      .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var defaultMap = await loadLocalizationMap(enUsTextLocale);
    var map = defaultMap;
    var textLocale = TextLocale(locale.toString());
    if (textLocale != enUsTextLocale) {
      try {
        map = await loadLocalizationMap(textLocale);
      } catch (_) {
        // No file for that locale, english only.
      }
    }
    return SynchronousFuture<AppLocalizations>(
      AppLocalizations(locale, map, defaultMap),
    );
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [AppLocalizationsDelegate()],
      supportedLocales: AppLocalizationsDelegate.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.t('My application'))),
      body: Center(child: Text(localizations.t('Hello ', {'name': 'Bob'}))),
    );
  }
}
```

### Assets shipped by a library package

```dart
import 'package:tekartik_app_flutter_intl/intl.dart';

/// The json files live in <my_ui_package>/assets/i18n/, the runner app only
/// depends on the package; the loader resolves
/// packages/my_ui_package/assets/i18n/<locale>.json.
Future<Map<String, String>> loadPackageLocale(TextLocale textLocale) =>
    loadLocalizationMap(textLocale, package: 'my_ui_package');
```

### Unit testing the pure helpers

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_intl/intl.dart';

void main() {
  test('localization map', () {
    var map = intlDecodeLocalizationMap(
      '{"Hello {{name}}": "Bonjour {{name}}", "Cancel": "Annuler"}',
    );
    // The key is truncated at the first {{.
    expect(map.keys, contains('Hello '));
    expect(intlSafeKey('Hello {{name}}'), 'Hello ');
    expect(
      intlText(map, 'Hello ', data: {'name': 'Bob'}),
      'Bonjour Bob',
    );
    expect(intlText(map, 'Missing'), '[Missing]');
    expect(intlRender('a {{x}} b', data: {'x': 'c'}), 'a c b');
  });
}
```

## Common mistakes

* Forgetting the `assets: - assets/i18n/` entry in `pubspec.yaml`, or naming
  the folder differently: the path is hardcoded.
* Naming a file after the language only (`fr.json`) while passing
  `TextLocale('fr_FR')`, or vice versa - the file name is exactly
  `TextLocale.name`.
* Omitting `package:` when the json assets belong to a library package.
* Looking a parameterized text up by its full source text (`'Hello {{name}}'`)
  instead of the safe key (`'Hello '`).
* Passing a null value in `data`: `intlRender` force-unwraps it.
* Awaiting `loadLocalizationMap` in a unit test without
  `TestWidgetsFlutterBinding.ensureInitialized()`.
