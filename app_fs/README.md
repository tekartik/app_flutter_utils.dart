f# tekartik_app_flutter_fs

FileSystem for flutter app (mobile & web)

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_flutter_fs:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_fs
    version: '>=0.1.0'
```

### Usage

```dart
import 'package:tekartik_app_flutter_fs/fs.dart';

Future main() async {
  await fs.File('test').writeString('hello'); 
}
```
