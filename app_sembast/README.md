# tekartik_app_flutter_sembast

Sembast factory for flutter app (mobile & web)

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