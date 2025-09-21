# tekartik_app_flutter_widget

Common widgets

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_flutter_widget:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_widget
    version: '>=0.2.1'
```

### Usage

#### FutureOrBuilder

```dart
var ready = false;

Future<String> _getReady() async {
  // Getting ready
  // ... doStuff
  ready = true;
  return 'done';
}

FutureOr<String> _loadData() {
  // ... do Stuff
  if (!ready) {
    return _getReady();
  }
  return 'done';
}

return MaterialApp(
  home: FutureOrBuilder<String>(
  futureOr: _loadData(),
  builder: (context, snapshot) =>
    Text(snapshot.data ?? 'no data')));
```

