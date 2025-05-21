import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_flutter_widget/will_pop_scope_compat.dart';
import 'package:tekartik_test_menu_flutter/test.dart';

void menuWillPopScopeCompat() {
  menu('will_pop_scope_compat', () {
    item('simple', () async {
      var result = await navigator.push<Object?>(
        MaterialPageRoute(builder: (_) => const SimpleScreen()),
      );
      write('result: $result');
    });
    item('simple override', () async {
      var result = await navigator.push<Object?>(
        MaterialPageRoute(builder: (_) => const SimpleOverrideScreen()),
      );
      write('result: $result');
    });
  });
}

class SimpleScreen extends StatelessWidget {
  const SimpleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScopeCompat(
      onWillPop: () async {
        var result = await muiConfirm(context, message: 'Confirm exit?');
        return result;
      },
      child: muiScreenWidget('Test WillPopScopeCompat', () {
        muiItem('Pop null', () {
          Navigator.of(context).pop();
        });
        muiItem('Pop Some Text', () {
          Navigator.of(context).pop('Some Text');
        });
      }),
    );
  }
}

class SimpleOverrideScreen extends StatelessWidget {
  const SimpleOverrideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScopeCompat(
      onWillPop: () async {
        var result = await muiConfirm(
          context,
          message: 'Exit ? or pop Some Text (no)',
        );
        if (result) {
          return true;
        }
        if (context.mounted) {
          Navigator.of(context).pop('Some Text');
        }
        return false;
      },
      child: muiScreenWidget('Test WillPopScopeCompat', () {
        muiItem('Pop null', () {
          Navigator.of(context).pop();
        });
        muiItem('Pop Some Text', () {
          Navigator.of(context).pop('Some Text');
        });
      }),
    );
  }
}
