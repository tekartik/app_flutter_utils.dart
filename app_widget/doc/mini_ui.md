## Example

```dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';

Future<void> main() async {
  runApp(MaterialApp(
    home: MuiScreenWidget(items: [
      MuiItem('item', () {
        muiSnack(muiBuildContext, 'tap');
      }),
      MuiItem('sub', () async {
        var result = await showMuiMenu<Object?>(muiBuildContext, 'simple', () {
          muiItem('Pop', () => Navigator.of(muiBuildContext).pop(null));
          muiItem('Pop Some text',
              () => Navigator.of(muiBuildContext).pop('Some text'));
          muiItem('Snack Some text', () {
            muiSnack(muiBuildContext, 'Some text');
          });
        });
        // ignore: unawaited_futures
        muiSnack(muiBuildContext, 'result $result');
      })
    ], name: 'main'),
  ));
}
```