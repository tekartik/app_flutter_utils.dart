# tekartik_app_flutter_utils_test_app

Flutter test application of this repository: one dev menu
(`tekartik_app_dev_menu_flutter`) gathering the menus of the
`example/*_test_app_lib` packages (prefs, idb, fs, sembast, sqflite, list
view, sdb ui, widgets, full screen, app plugin, common, common web,
navigator, image, roboto) and a `platform` menu. Not meant to be a
dependency.

Entry points: `lib/main.dart` (every menu) and `lib/main_menu.dart` (the
platform context and the shell environment only).

## Run

The platform folders are not in git (`example/.gitignore`), create them
first:

```bash
flutter create .
flutter run
```

On the web, the sqflite menu needs the sqflite web binaries in `web/`
(`sqflite_sw.js`, `sqlite3.wasm`), copied by:

```bash
dart run tool/setup_sqflite_web.dart
flutter run -d chrome
```

`dart run tool/clean_build_and_run_web_wasm.dart` builds the web app with
`--wasm` and serves `build/web` on http://localhost:8080 (dhttpd, with the
cross origin isolation headers).
