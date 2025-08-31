import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launch a new page/tag or external browser (mobile, web, desktop)
void webLaunchUri(Uri uri) {
  if (kDebugMode) {
    print(uri);
  }
  launchUrl(uri, webOnlyWindowName: '_blank');
}
