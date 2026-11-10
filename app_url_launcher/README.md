# tekartik_app_url_launcher_flutter

One fire and forget helper over
[url_launcher](https://pub.dev/packages/url_launcher): `webLaunchUri(uri)`
opens a link, a `mailto:` or a `tel:` uri in a new tab on the web and in the
platform handler elsewhere.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_url_launcher_flutter:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_url_launcher
```

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_url_launcher_flutter/web_launch_uri.dart';

Widget helpLink() => GestureDetector(
  // Straight from the gesture: no popup blocker on the web.
  onTap: () => webLaunchUri(Uri.https('example.com', '/help')),
  child: const Text('Online help', textDirection: TextDirection.ltr),
);
```

Complete app in [example/main.dart](example/main.dart).

## Platforms

| Platform | `https:` | other schemes (`mailto:`, `tel:`) |
|---|---|---|
| Web | a new tab (`_blank`), the app stays loaded | the browser handler |
| Android | an in-app browser view (Custom Tabs) | the app that handles it |
| iOS | an in-app browser view (SFSafariViewController) | the app that handles it |
| macOS, Linux, Windows | the default browser | the default app |

`url_launcher` platform setup still applies: the `<queries>` entries of
`AndroidManifest.xml`, `LSApplicationQueriesSchemes` in `Info.plist` for
non http schemes.

## Common pitfalls

- `webLaunchUri` returns nothing and never throws: a failure (no app for a
  `tel:` uri on a tablet, url_launcher throws there) is only logged in debug
  mode (fixed 2026-11-10: it was an uncaught error). Call `launchUrl` of
  url_launcher yourself to know the result or to pick a `LaunchMode`.
- Build the uri with `Uri.https(host, path, query)` or `Uri(scheme: 'mailto',
  ...)`, not by concatenating strings.
- Tests: inject the launcher (`void Function(Uri) launch = webLaunchUri`) and
  pass a recording function.

Agent skill:
[tekartik-app-url-launcher-flutter-setup](skills/tekartik-app-url-launcher-flutter-setup/SKILL.md).
