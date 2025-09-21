# tekartik_app_flutter_sembast

This package allow a simplified sembast initialization to support multiple platforms (flutter mobile/desktop and web).
The abstraction is done at the database factory used within an application.

Sembast database factory for flutter app (mobile & web).

* On Flutter iOS/Android/MacOS, [sembast_sqflite](https://pub.dev/packages/sembast_sqflite) will be used based on 
  [sqflite](https://pub.dev/packages/sqflite)
* On Flutter Desktop Windows/Linux/(optional MacOS), [sembast_sqflite](https://pub.dev/packages/sembast_sqflite) will be used 
  based on [sqflite_commmon_ffi](https://pub.dev/packages/sqflite_common_ffi)
* On Flutter Web, [sembast_web](https://pub.dev/packages/sembast_web) will be used based on
  IndexedDB
* In unit test, `databaseFactoryMemory` should be used from [sembast](https://pub.dev/packages/sembast)

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_flutter_sembast:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_sembast
    version: '>=0.1.0'
```

### Usage

Simplified usage: 
* Open your database only once in your application 
* Keep it open

```dart
import 'package:tekartik_app_flutter_sembast/sembast.dart';
Future main() {
  // Get the sembast database factory according to the current platform
  // * sembast_web for FlutterWeb and Web
  // * sembast_sqflite and sqflite on Flutter iOS/Android/MacOS
  // * sembast_sqflite and sqflite3 ffi on Flutter Windows/Linux and dart VM (might require extra initialization steps)
  var factory = getDatabaseFactory();
  var store = StoreRef<String, String>.main();
  // Open the database
  var db = await factory.openDatabase('test.db');
  await store.record('key').put(db, 'value');
  
  // Not needed in a flutter application
  await db.close();
}
```

### Usage in unit test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

void main() {
  test('open/close', () async {
    /// Using in memory implementation for unit test
    var factory = databaseFactoryMemory;
    var db = await factory.openDatabase('test.db');
    // ...
    await db.close();
  });
}
```

# Sample usage

* [Flutter counter template with added persistency](https://github.com/alextekartik/flutter_app_example/tree/master/demosembast) available, [online demo](https://alextekartik.github.io/flutter_app_example/demosembast)
* Basic [notepad using sembast](https://github.com/alextekartik/flutter_app_example/tree/master/notepad_sembast) available, [online demo](https://alextekartik.github.io/flutter_app_example/notepad_sembast/)
