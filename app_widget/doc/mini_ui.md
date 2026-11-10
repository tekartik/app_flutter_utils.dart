## Mini UI example

A menu screen built from `MuiItem`s, a sub menu returning a value. Keep the
context of the tile (`muiBuildContext`) before an `await`: the global
changes with the next tap (here, a tap in the sub menu).

```dart
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';

void main() {
  runApp(
    MaterialApp(
      home: MuiScreenWidget(
        name: 'main',
        items: [
          MuiItem('item', () {
            muiSnackSync(muiBuildContext, 'tap');
          }),
          MuiItem('sub', () async {
            var context = muiBuildContext;
            var result = await showMuiMenu<String>(context, 'simple', () {
              muiItem('Pop', () => Navigator.of(muiBuildContext).pop());
              muiItem(
                'Pop Some text',
                () => Navigator.of(muiBuildContext).pop('Some text'),
              );
            });
            if (context.mounted) {
              muiSnackSync(context, 'result $result');
            }
          }),
        ],
      ),
    ),
  );
}
```
