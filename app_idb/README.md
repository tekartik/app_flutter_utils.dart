# tekartik_app_flutter_idb

IDB factory for flutter app (mobile & web).

Uses sqflite on Mobile/Desktop and indexed db on the web.

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_flutter_idb:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_idb
    version: '>=0.1.0'
```

### Usage

```dart
import 'package:tekartik_app_flutter_idb/idb.dart';

Future<Database> open() async {
  var db = await idbFactory.open('test.db', version: 1,
      onUpgradeNeeded: (e) {
    if (e.oldVersion < 1) {
      e.database.createObjectStore('simple');
    }
  });
  return db;
}
```
