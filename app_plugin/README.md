# tekartik_app_flutter_plugin

Flutter plugin with platform features 

## Setup

`pubspec.yaml` dependencies:

```yaml
tekartik_app_flutter_plugin:
  git:
    url: https://github.com/tekartik/app_flutter_utils.dart
    path: app_plugin
  version: '>=0.1.0'
```

## Test if monkey is running

Assuming you run the following shell script

```bash
adb shell monkey -p $packageName -v --pct-touch 98 --pct-majornav 1 --pct-motion 1 5000 
```

You can check whether monkey testing is running from dart code using

```dart
if (await isMonkeyRunning) {
  // Do a specific action while monkey is running
} else {
  // Monkey testing is not running
}
```
