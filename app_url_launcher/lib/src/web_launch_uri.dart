import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launch a new page/tag or external browser (mobile, web, desktop)
///
/// Fire and forget: a failure (no app for the uri, such as `tel:` on a
/// tablet, where url_launcher throws) is only logged in debug mode, never
/// thrown nor left uncaught.
void webLaunchUri(Uri uri) {
  if (kDebugMode) {
    print(uri);
  }

  unawaited(
    launchUrl(uri, webOnlyWindowName: '_blank').then<void>(
      (launched) {
        if (!launched && kDebugMode) {
          debugPrint('webLaunchUri($uri) not launched');
        }
      },
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('webLaunchUri($uri) failed: $error');
        }
      },
    ),
  );
}
