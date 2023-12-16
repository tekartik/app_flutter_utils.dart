import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_common_utils/common_utils_import.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_test_menu_flutter/test.dart';

void menuMinuUi() {
  menu('Mini ui', () {
    item('showMuiMenu', () async {
      var result = await showMuiMenu<Object?>(
          castAsNullable(buildContext)!, 'simple', () {
        muiItem('Pop', () => Navigator.of(muiBuildContext).pop(null));
        muiItem('Pop Some text',
            () => Navigator.of(muiBuildContext).pop('Some text'));
        muiItem('Snack Some text', () {
          muiSnack(muiBuildContext, 'Some text');
        });
      });
      write('result: $result');
    });

    item('subMenu', () async {
      var result = await showMuiMenu<Object?>(
          castAsNullable(buildContext)!, 'simple', () {
        muiItem('Pop', () => Navigator.of(muiBuildContext).pop(null));

        muiMenu('sub', () {
          muiItem('Pop Sub', () => Navigator.of(muiBuildContext).pop(null));
          muiItem('Pop Sub Some text',
              () => Navigator.of(muiBuildContext).pop('Sub Some text'));

          muiItem('showMuiMenu', () async {
            var result = await showMuiMenu<Object?>(
                castAsNullable(buildContext)!, 'simple', () {
              muiItem('Pop', () => Navigator.of(muiBuildContext).pop(null));
              muiItem('Pop Some text',
                  () => Navigator.of(muiBuildContext).pop('Some text'));
            });
            write('result: $result');
          });
        });
        muiItem('Pop Some text',
            () => Navigator.of(muiBuildContext).pop('Some text'));
      });
      write('result: $result');
    });
  });
}
