# tekartik_app_flutter_idb

IDB factory for flutter app (mobile & web)

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_emit_builder:
    git:
      url: git://github.com/tekartik/app_flutter_utils.dart
      ref: dart2
      path: app_idb
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