# tekartik_app_flutter_widget

Small Flutter widgets shared by the tekartik apps:

- `mini_ui.dart`: quick dialogs (confirm, text input, pick from a list,
  snack) and a declarative dev/test menu screen;
- `view/cv_ui.dart`: a generic viewer/editor of a `cv` `CvModel` (debug and
  admin screens);
- views: `FutureOrBuilder`, `WithHeaderFooterListView`, progress
  placeholders, a busy screen mixin, `BodyContainer`, `FadeIn`,
  `DelayedDisplay`, `AppScrollBehavior`, `WillPopScopeCompat`.

Flutter only (Android, iOS, macOS, Linux, Windows, web), no plugin. Built on
`package:material_ui` (the Material library outside the Flutter SDK).

## Getting started

```yaml
dependencies:
  tekartik_app_flutter_widget:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_widget
  material_ui: '>=1.5.0'
```

```dart
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';

void main() {
  runApp(
    MaterialApp(
      home: muiScreenWidget('demo', () {
        muiItem('Ask a name', () async {
          var context = muiBuildContext;
          var name = await muiGetString(context, title: 'Your name');
          if (name != null && context.mounted) {
            muiSnackSync(context, 'Hello $name');
          }
        });
      }),
    ),
  );
}
```

A complete example (dialogs, a cv model editor, a back confirmation):
[example/main.dart](example/main.dart).

## What to import

| Import | Content |
| --- | --- |
| `mini_ui.dart` | `muiConfirm`, `muiGetString`, `muiSelectString`, `muiSnack`, `muiScreenWidget`, `muiBodyWidget`, `muiMenu`, `muiItem`, `showMuiMenu`, `muiBuildContext` |
| `view/cv_ui.dart` | `CvUiModelView`, `CvUiModelEdit` + `CvUiModelEditController`, the value widgets |
| `app_widget.dart` | `CenteredProgress`, `SmallProgress`, `SmallConnectivityError`, `FutureOrBuilder`, `WithHeaderFooterListView` |
| `view/*.dart` | `busy_indicator.dart`, `busy_screen_state_mixin.dart`, `body_container.dart`, `tile_padding.dart`, `fade_in.dart`, `future_or_builder.dart`, `with_header_footer_list_view.dart`, `all_widget_for_theming.dart` |
| `delayed_display.dart`, `scroll_behavior.dart`, `will_pop_scope_compat.dart` | `DelayedDisplay`, `AppScrollBehavior`, `WillPopScopeCompat` |

Never import `lib/src/`.

## Pitfalls

- Use `package:material_ui/material_ui.dart` in the app, not
  `package:flutter/material.dart`: a widget of one Material library under
  the `MaterialApp`/`Scaffold` of the other fails (`No MaterialLocalizations
  found`, `No Material widget found`).
- `mini_ui` is for dev and test screens. `muiBuildContext` is the context
  of the tapped tile, valid during the item callback only; check
  `context.mounted` after an `await`.
- `muiGetString` returns null on cancel; while its validator rejects the
  text, the dialog stays open.
- `WillPopScopeCompat(onWillPop:)` vetoes back until `onWillPop` returns
  true; without `onWillPop` the route pops as usual.
- `CvUiModelEdit` edits the model in place (no save, no cancel: pass a
  copy). The expand/collapse state of the tree is lost when it is rebuilt
  (each edit rebuilds it).
- `BusyScreenStateMixin`: call `busyDispose()` in `dispose()` (or use
  `AutoDisposedBusyScreenStateMixin`); `busy` does not rebuild the screen,
  listen to `busyStream` (`BusyIndicator`).
- `FutureOrBuilder`: compute the future once (in `initState`), not in
  `build()`.

More in the package skills: [mini_ui](skills/tekartik-app-flutter-widget-mini-ui/SKILL.md),
[cv_ui](skills/tekartik-app-flutter-widget-cv-ui/SKILL.md),
[views](skills/tekartik-app-flutter-widget-views/SKILL.md).
