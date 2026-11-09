# tekartik_app_flutter_common_web_utils

Flutter web helpers callable from code shared with mobile and desktop: the
url strategy (`/settings` instead of `/#/settings`, overridable from the page
url) and hiding the mouse cursor (kiosk, TV). Off the web they do nothing, so
`main()` calls them without `kIsWeb` checks.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_flutter_common_web_utils:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_common_web
```

```dart
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_common_web_utils/url_strategy.dart';

void main() {
  // Path urls on the web (`/settings`), noop elsewhere. Once, before runApp.
  webUsePathUrlStrategy();
  runApp(const Center(child: Text('home', textDirection: TextDirection.ltr)));
}
```

Platforms: every Flutter platform; the web does the work, the others no-op.
Complete app in [example/main.dart](example/main.dart).

## Url strategy (`url_strategy.dart`)

- `webUsePathUrlStrategy()`, `webUseHashUrlStrategy()`,
  `webUseUrlStrategy(WebUrlStrategy.path)`: call one, once, before `runApp`
  (Flutter asserts on a second call). The path strategy needs a server that
  serves `index.html` for every path (Firebase Hosting rewrites, the
  `flutter run` server) and a `<base href>` in `index.html`.
- The page can enforce the strategy whatever the app asks for, e.g. to use a
  static server without rewrites:
  - `?url-strategy=hash` in the page url (before the `#`):
    `/?url-strategy=hash#/settings`, the parameter stays in the url;
  - `?url-strategy=path`: `/settings`;
  - `<meta name="url-strategy" content="hash">` in the page (what a server
    rewriting the entry can inject); the url parameter wins over it.
- `webIsPathUrlStrategy` and `webIsHashUrlStrategy` tell which one is in use
  (both false off the web). `setPathUrlStrategy()` /
  `setHashUrlStrategy()` are the older names.

## Cursor (`cursor_utils.dart`)

`hideCursor()` / `showCursor()` (futures, resolved at once): on the web the
`<flutter-view>` style gets `cursor: none;` (or `cursor: default;`),
re-applied every second by a background loop; the state is global for the
page.

## Common pitfalls

- `?url-strategy=path` is lost at the first navigation (the path strategy
  pushes the route path without the page query): a reload then uses the
  app's own strategy. Use the meta tag to keep it.
- The cursor shows again over interactive widgets (buttons, text fields set
  their own cursor on the same element) until the pointer leaves them; it is
  hidden at most a second after `hideCursor()`.
- Nothing to test off the web: check the behaviour with
  `flutter run -d chrome`.

Agent skill:
[tekartik-app-flutter-common-web-utils-setup](skills/tekartik-app-flutter-common-web-utils-setup/SKILL.md).
