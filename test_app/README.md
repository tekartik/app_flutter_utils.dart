# tekartik_app_flutter_test_app

Flutter test application for some packages of this repository: a dev menu
(`tekartik_app_dev_menu_flutter`) with an `fs` menu (application documents
directory) and a `monkey` menu (`isMonkeyRunning` of
`tekartik_app_flutter_plugin`, Android only). Not meant to be a dependency.

## Run

The platform folders are not in git, create them first (the org is the one
`tool/monkey_run.dart` expects):

```bash
flutter create --org com.tekartik --project-name tekartik_app_flutter_test_app .
flutter run
```

## Monkey test (Android)

With the app installed on a connected device, `dart run tool/monkey_run.dart`
runs `adb shell monkey` on `com.tekartik.tekartik_app_flutter_test_app`; the
`monkey` menu item "start checking isMonkeyRunning every 500ms" prints it.
