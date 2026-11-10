import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:tekartik_app_intl/intl.dart';

/// The localization map of [textLocale], read from the asset
/// `assets/i18n/<textLocale.name>.json` (declare `assets/i18n/` in the app
/// pubspec), `packages/<package>/assets/i18n/...` when [package] is set (the
/// assets of a library package).
///
/// The keys are safe keys (see `intlSafeLocalizationMap`). Throws (a
/// `FlutterError`) when the asset is missing; there is no fallback locale:
/// load the default map too and pass it to `intlText`.
Future<Map<String, String>> loadLocalizationMap(
  TextLocale textLocale, {
  String? package,
}) async {
  var path = url.join('assets', 'i18n', '${textLocale.name}.json');
  if (package != null) {
    path = url.join('packages', package, path);
  }
  var jsonString = await rootBundle.loadString(path);
  return intlDecodeLocalizationMap(jsonString);
}
