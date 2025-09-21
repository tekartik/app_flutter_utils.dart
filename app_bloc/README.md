# tekartik_app_flutter_bloc

Basic bloc provider

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_flutter_bloc:
    git:
      url: https://github.com/tekartik/app_flutter_utils.dart
      path: app_bloc
    version: '>=0.2.2'
```

### Usage

```dart
class TestBloc extends BaseBloc {
  final String value = 'test_result';
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: BlocProvider(
      blocBuilder: () => TestBloc(),
      child: Scaffold(
        body: ListView(
          children: [
            Builder(builder: (context) {
              return Text(BlocProvider.of<TestBloc>(context).value);
            })
          ],
        ),
      ),
    ));
  }
}
```
