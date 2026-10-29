## tekartik_app_agent_flutter

Flutter helpers for the apps an agent (an LLM, a test tool) drives:

- `AgentId('play', child: button)`: a stable id on a widget
  (`Semantics(identifier:)`), the Android `resource-id`, the iOS
  `accessibilityIdentifier`, the web `flt-semantics-identifier`, merged with
  the label and the tap of the control (`container: true` for a group whose
  children keep their own ids). Keep the ids in one constants file per app,
  shared with its tools.
- `agentInit()`: reads the `?semantics` / `?agent` options of the page url
  (`AgentUrlOptions`, also in a hash url fragment) and builds the semantics
  from the start when they ask for it, so that the web semantics DOM (and
  its ids) exists without the "enable accessibility" button.

A tool drives the web app by these ids with `AgentWebPage` of
`tekartik_app_agent`
([app_common_utils.dart](https://github.com/tekartik/app_common_utils.dart)).

## Setup

```yaml
  tekartik_app_agent_flutter:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_agent
```

```dart
import 'package:tekartik_app_agent_flutter/app_agent_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  agentInit();
  runApp(const MyApp());
}
```
