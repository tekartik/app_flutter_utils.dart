# tekartik_app_flutter_utils/app_prefs

Prefs helper for flutter application. It uses sqflite on mobile and indexed db
on the web.

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_prefs:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_prefs
    version: '>=0.1.0'
```

### Usage

```dart
import 'package:tekartik_app_prefs/app_prefs.dart';

// Get the default persistent prefs factory.
var prefsFactory = getPrefsFactory();
var prefs = await prefsFactory.openPreferences('my_shared_prefs');

// Once you have a [Prefs] object ready, use it. You can keep it open.
prefs.setInt('value', 26);
var title = prefs.getString('title');
```

Linux/Windows

```dart
// For Windows/Linux support you can add package name to find a shared
// location on the file system
var prefsFactory = getPrefsFactory(packageName: 'my.package.name');
```

In unit test:

```dart
// In memory prefs factory.
var prefsFactory = prefsFactoryMemory;
```
