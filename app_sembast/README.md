# tekartik_app_flutter_sembast

Sembast database factory for flutter app (mobile & web).

* On Flutter iOS/Android/MacOS, [sembast_sqflite](https://pub.dev/packages/sembast_sqflite) will be used based on 
  [sqflite](https://pub.dev/packages/sqflite)
* On Flutter Desktop Windows/Linux/MacOS, [sembast_sqflite](https://pub.dev/packages/sembast_sqflite) will be used 
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
      url: git://github.com/tekartik/app_flutter_utils.dart
      ref: dart2
      path: app_sembast
    version: '>=0.1.0'
```

### Usage

```dart
import 'package:tekartik_app_flutter_idb/app_sembast.dart';

var store = StoreRef<String, String>.main();
var db = await factory.openDatabase('test.db');
await store.record('kkey').put(db, 'value');
await db.close();
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