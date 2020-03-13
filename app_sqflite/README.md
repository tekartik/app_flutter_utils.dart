# tekartik_app_flutter_idb

IDB factory for flutter app (mobile & web)

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_flutter_sqflite:
    git:
      url: git://github.com/tekartik/app_flutter_utils.dart
      ref: dart2
      path: app_sqflite
    version: '>=0.1.0'
```

### Usage

```dart
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

Future<Database> open() async {
  var db = await databaseFactory.openDatabase('test.db');
  return db;
}
```