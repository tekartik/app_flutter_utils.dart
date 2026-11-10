// Shows a translated greeting. The maps come from assets/i18n/<locale>.json
// in an app; this example falls back to inline json when the assets are
// missing.
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_intl/intl.dart';

const _englishJson = '{"Hello {{name}}": "Hello {{name}}"}';
const _frenchJson = '{"Hello {{name}}": "Bonjour {{name}}"}';

/// The map of [textLocale] from the assets, [fallbackJson] when missing.
Future<Map<String, String>> loadMap(
  TextLocale textLocale,
  String fallbackJson,
) async {
  try {
    return await loadLocalizationMap(textLocale);
  } catch (_) {
    // No assets/i18n/<locale>.json declared in this example.
    return intlDecodeLocalizationMap(fallbackJson);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loaded before runApp: the first frame has its text.
  var english = await loadMap(enUsTextLocale, _englishJson);
  var french = await loadMap(frFrTextLocale, _frenchJson);
  var text = intlText(
    french,
    // The safe key: the text before {{.
    'Hello ',
    data: {'name': 'Bob'},
    defaultLocalizationMap: english,
  );
  runApp(Center(child: Text(text, textDirection: TextDirection.ltr)));
}
