---
name: tekartik-app-url-launcher-flutter-setup
description: >-
  Use when a Flutter app must open an external link, mailto:, tel: or custom
  scheme Uri in a new tab or in the system browser/app, with
  tekartik_app_url_launcher_flutter: the
  package:tekartik_app_url_launcher_flutter/web_launch_uri.dart import and its
  single webLaunchUri(Uri) helper, which wraps url_launcher's launchUrl with
  webOnlyWindowName '_blank' so the web build opens a new tab instead of
  replacing the app.
---

# Opening external links (tekartik_app_url_launcher_flutter)

A one function helper over `url_launcher`: `webLaunchUri(uri)` opens a `Uri`
in a new tab on the web and in the system browser/app on mobile and desktop,
with no boilerplate at the call site.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_url_launcher_flutter:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_url_launcher
      version: '>=1.0.0'
  ```
* One public library with one symbol:
  ```dart
  import 'package:tekartik_app_url_launcher_flutter/web_launch_uri.dart';
  ```
  exports `void webLaunchUri(Uri uri)` only. Never import anything under
  `lib/src/`.
* It calls `url_launcher`'s `launchUrl(uri, webOnlyWindowName: '_blank')`:
  * web: a new browser tab/window, the Flutter app stays loaded;
  * android/ios/macos/linux/windows: `webOnlyWindowName` is ignored and the
    OS picks the handler (browser for `https:`, mail client for `mailto:`,
    dialer for `tel:`);
  * in debug mode it also `print`s the uri.
* The function is **synchronous and returns void**: the underlying `Future`
  is not awaited and a failure is not reported back. Do not write
  `await webLaunchUri(...)` or test its result. When you need the boolean
  result, a `LaunchMode`, `canLaunchUrl`, or in-app webview / custom tabs,
  add `url_launcher` to your own `dependencies` and call `launchUrl`
  directly - this helper is deliberately the fire-and-forget shortcut.
* Always pass a real `Uri`, built with `Uri.parse('https://...')`,
  `Uri.https(host, path, queryParameters)` or
  `Uri(scheme: 'mailto', path: ..., queryParameters: ...)`, so query
  parameters get encoded. Never string-concatenate a url with user data.
* Call it from a user gesture (`onPressed`, `onTap`, a `TapGestureRecognizer`)
  and synchronously: browsers block a popup opened later from an async
  continuation, which is exactly what `_blank` does on the web.
* Platform configuration is `url_launcher`'s: non `http(s)` schemes need the
  `<queries>` entries in `AndroidManifest.xml` and
  `LSApplicationQueriesSchemes` in `Info.plist`. Nothing extra is required by
  this package.
* Tests: `webLaunchUri` reaches a platform channel, which a plain
  `flutter test` does not provide. Keep it out of unit tested logic - inject
  it (`void Function(Uri) launch = webLaunchUri`) and pass a recording
  function in tests.

## Examples

### Link button

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_url_launcher_flutter/web_launch_uri.dart';

class HelpLink extends StatelessWidget {
  const HelpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      /// Synchronous, straight from the gesture: no popup blocker on the web.
      onPressed: () => webLaunchUri(Uri.parse('https://example.com/help')),
      child: const Text('Online help'),
    );
  }
}
```

### Built uris: search, mail and phone

```dart
import 'package:tekartik_app_url_launcher_flutter/web_launch_uri.dart';

/// Uri.https encodes the query parameters.
void searchOnline(String query) {
  webLaunchUri(Uri.https('example.com', '/search', {'q': query}));
}

void sendFeedback({required String to, required String subject}) {
  webLaunchUri(
    Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: <String, String>{'subject': subject},
    ),
  );
}

void call(String phoneNumber) {
  webLaunchUri(Uri(scheme: 'tel', path: phoneNumber));
}
```

### Injectable launcher, testable

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_url_launcher_flutter/web_launch_uri.dart';

typedef UriLauncher = void Function(Uri uri);

class AboutController {
  /// Defaults to the real launcher, tests pass a recording function.
  final UriLauncher launch;

  AboutController({UriLauncher? launch}) : launch = launch ?? webLaunchUri;

  void openLicense() => launch(Uri.parse('https://example.com/license'));
}

class AboutTile extends StatelessWidget {
  final AboutController controller;

  const AboutTile({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('License'),
      onTap: controller.openLicense,
    );
  }
}

/// In a test: no platform channel involved.
void exampleTest() {
  var launched = <Uri>[];
  AboutController(launch: launched.add).openLicense();
  print(launched.single);
}
```
