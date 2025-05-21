import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:tekartik_app_intl/intl.dart';

/// Load localization map from an asset
Future<Map<String, String>> loadLocalizationMap(
  TextLocale textLocale, {
  String? package,
}) async {
  // Load the language JSON file from the "lang" folder

  var path = url.join('assets', 'i18n', '${textLocale.name}.json');
  if (package != null) {
    path = url.join('packages', package, path);
  }
  // Always load english
  var jsonString = await rootBundle.loadString(path);
  return intlDecodeLocalizationMap(jsonString);
}
