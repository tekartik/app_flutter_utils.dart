## Setup

```yaml
  tekartik_app_flutter_common_web_utils:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_common_web
    version: '>=0.1.0'
```

## Url strategy

```dart
import 'package:tekartik_app_flutter_common_web_utils/url_strategy.dart';

void main() {
  // Path urls on the web (`/settings`), noop elsewhere.
  webUsePathUrlStrategy();
  runApp(...);
}
```

The page url can enforce the strategy whatever the app asks for, e.g. to use
a static server without rewrites:
- `?url-strategy=hash`: `/?url-strategy=hash#/settings`, the parameter stays in
  the url.
- `?url-strategy=path`: `/settings`.

`webIsPathUrlStrategy` and `webIsHashUrlStrategy` tell which one is in use
(both false off the web).
