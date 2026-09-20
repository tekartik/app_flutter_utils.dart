---
name: tekartik-app-flutter-widget-views
description: >-
  Use when a Flutter screen needs the common tekartik_app_flutter_widget
  building blocks: FutureOrBuilder for a FutureOr value,
  WithHeaderFooterListView.builder/.separated, CenteredProgress, SmallProgress,
  SmallConnectivityError, BusyIndicator with a ValueStream<bool>, the
  BusyScreenStateMixin / AutoDisposedBusyScreenStateMixin busyAction /
  busyStream / BusyActionResult pattern, BodyContainer, TilePadding
  (BodyHPadding), FadeIn with FadeInController, DelayedDisplay,
  AppScrollBehavior, WillPopScopeCompat and AllWidgetForTheming.
---

# Common widgets and busy screens (tekartik_app_flutter_widget)

A grab bag of small widgets used across tekartik Flutter apps: async builders,
progress placeholders, list/layout helpers and a "busy screen" state mixin
that serializes an async action behind a progress bar.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_flutter_widget:
      git:
        url: https://github.com/tekartik/app_flutter_utils.dart
        path: app_widget
      version: '>=0.2.1'
  ```
* Each widget lives in its own small library; import only what you need and
  never anything under `lib/src/`:
  * `package:tekartik_app_flutter_widget/app_widget.dart` - `CenteredProgress`,
    `SmallProgress`, `SmallConnectivityError`, plus `FutureOrBuilder` and
    `WithHeaderFooterListView` for compatibility.
  * `view/future_or_builder.dart`, `view/with_header_footer_list_view.dart`,
    `view/busy_indicator.dart`, `view/busy_screen_state_mixin.dart`,
    `view/body_container.dart`, `view/tile_padding.dart`,
    `view/body_h_padding.dart` (a `BodyHPadding = TilePadding` typedef),
    `view/fade_in.dart`, `view/all_widget_for_theming.dart`.
  * `delayed_display.dart`, `scroll_behavior.dart`,
    `will_pop_scope_compat.dart`, `color.dart` (a compat re-export of
    `tekartik_app_flutter_common_utils/color.dart`).
* `FutureOrBuilder<T>(futureOr: value, builder: (context, snapshot) => ...)`
  takes a `FutureOr<T>`: a plain value builds **synchronously** with a
  `ConnectionState.done` snapshot (no empty frame), a `Future` falls back to
  `FutureBuilder`. Use it for "cached or loaded" data; always handle
  `snapshot.data == null` for the future case.
* `WithHeaderFooterListView.builder(itemBuilder:, itemCount:, header:,
  footer:, padding:, shrinkWrap:)` or `.separated(..., separatorBuilder:)`
  adds a header/footer row **inside** the scrollable, so `itemCount` stays the
  data count and `itemBuilder` indexes are unshifted. Do not pass
  `separatorBuilder` to `.builder`.
* Progress placeholders: `CenteredProgress` (a centered
  `CircularProgressIndicator`, for a whole body), `SmallProgress` (sized on
  `IconTheme`, for a `ListTile` leading/trailing), `SmallConnectivityError`
  (a grey `Icons.cloud_off`).
* Busy screens, in `view/busy_screen_state_mixin.dart`:
  * `mixin BusyScreenStateMixin<T> on State<T>` owns a
    `BehaviorSubject<bool>` seeded `false`; call `busyDispose()` from
    `dispose()`.
  * `mixin AutoDisposedBusyScreenStateMixin<T> on State<T>` does the same but
    registers the subject with `audi*`, so use it on a state that already
    mixes in `AutoDispose` (for example `AutoDisposeBaseState` from
    `tekartik_app_rx_bloc_flutter`); no manual dispose then.
  * Both give (through `BusyScreenStateMixinExtension`): `busyStream` (a
    `ValueStream<bool>` to feed `BusyIndicator`), `busySink`, `bool get busy`
    and `Future<BusyActionResult<R>> busyAction<R>(Future<R> Function())`.
  * `busyAction` refuses to start while busy (it returns
    `BusyActionResult(busy: true)` with a null `result`), catches exceptions
    into `result.error` / `result.errorStackTrace` and always clears the busy
    flag. Check `result.busy` first, then `result.error`, then `result.result`
    - it never throws.
  * `BusyIndicator(busy: busyStream)` renders a `LinearProgressIndicator`
    while true and an empty `Container` otherwise; put it at the top of the
    body or in `PreferredSize`.
* Layout: `BodyContainer(width: 840, child: ...)` centers a max width column
  (good for desktop/web), `TilePadding(child: ...)` adds the 16px horizontal
  padding of a `ListTile` to a non tile widget.
* Animation: `DelayedDisplay(child:, delay:, fadingDuration:, slidingCurve:,
  slidingBeginOffset:, fadeIn:)` fades and slides a widget in (toggle `fadeIn`
  to reverse), `FadeIn(child:, controller:, duration:, curve:)` with a
  `FadeInController(autoStart: ...)` and its `fadeIn()` / `fadeOut()` methods
  (dispose the controller yourself).
* App level: `MaterialApp(scrollBehavior: AppScrollBehavior())` enables mouse
  and trackpad drag scrolling on desktop/web;
  `WillPopScopeCompat(onWillPop: () async => bool, child: ...)` is the
  `PopScope` based replacement of the removed `WillPopScope`;
  `AllWidgetForTheming()` renders a sample of every common widget, useful in a
  dev screen to eyeball a `ThemeData`.
* Anti-patterns: rebuilding a `FutureOrBuilder` with a freshly created
  `Future` on every `build()` (compute it in `initState` or make it
  synchronous), running two `busyAction`s in parallel and expecting both to
  run, forgetting `busyDispose()` with the non auto-disposed mixin.

## Examples

### FutureOr data, no loading flash when cached

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/app_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _cached;

  /// Synchronous once loaded: the builder runs with data on the first frame.
  FutureOr<String> _load() {
    var cached = _cached;
    if (cached != null) {
      return cached;
    }
    return Future<String>.delayed(
      const Duration(milliseconds: 200),
      () => _cached = 'loaded',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureOrBuilder<String>(
        futureOr: _load(),
        builder: (context, snapshot) {
          var data = snapshot.data;
          if (data == null) {
            return const CenteredProgress();
          }
          return Center(child: Text(data));
        },
      ),
    );
  }
}
```

### List with header and footer, inside a max width body

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/body_container.dart';
import 'package:tekartik_app_flutter_widget/view/tile_padding.dart';
import 'package:tekartik_app_flutter_widget/view/with_header_footer_list_view.dart';

class ItemListView extends StatelessWidget {
  final List<String> items;

  const ItemListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return BodyContainer(
      child: WithHeaderFooterListView.separated(
        itemCount: items.length,
        header: const TilePadding(child: Text('My items')),
        footer: const TilePadding(child: Text('End of list')),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => ListTile(title: Text(items[index])),
      ),
    );
  }
}
```

### Busy screen: one action at a time, progress bar and error

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/app_widget.dart';
import 'package:tekartik_app_flutter_widget/view/busy_indicator.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> with BusyScreenStateMixin<SyncPage> {
  String _status = 'idle';

  @override
  void dispose() {
    /// Closes the busy subject (not needed with AutoDisposedBusyScreenStateMixin).
    busyDispose();
    super.dispose();
  }

  Future<void> _sync() async {
    var result = await busyAction<int>(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      return 42;
    });
    if (!mounted) {
      return;
    }
    setState(() {
      if (result.busy) {
        _status = 'already running';
      } else if (result.error != null) {
        _status = 'failed: ${result.error}';
      } else {
        _status = 'synced ${result.result}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: BusyIndicator(busy: busyStream),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_status),
            ElevatedButton(onPressed: _sync, child: const Text('Sync')),
            if (busy) const SmallProgress(),
          ],
        ),
      ),
    );
  }
}
```

### App wiring: desktop scrolling, back confirmation, fade in

```dart
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/delayed_display.dart';
import 'package:tekartik_app_flutter_widget/scroll_behavior.dart';
import 'package:tekartik_app_flutter_widget/will_pop_scope_compat.dart';

void main() {
  runApp(
    MaterialApp(
      /// Mouse/trackpad drag scrolling on desktop and web.
      scrollBehavior: AppScrollBehavior(),
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<bool> _confirmExit() async => true;

  @override
  Widget build(BuildContext context) {
    return WillPopScopeCompat(
      onWillPop: _confirmExit,
      child: Scaffold(
        body: const DelayedDisplay(
          delay: Duration(milliseconds: 200),
          child: Center(child: Text('Welcome')),
        ),
      ),
    );
  }
}
```
