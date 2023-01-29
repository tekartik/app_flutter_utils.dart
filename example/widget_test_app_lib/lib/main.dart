import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/app_widget.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';

void defineMenu() {
  menu('widget', () {
    //devPrint('MAIN_');
    Widget centeredProgressScreen({ThemeData? themeData}) {
      return Theme(
          data: themeData ?? ThemeData.light(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('App Widget'),
            ),
            body: const CenteredProgress(),
          ));
    }

    item('CenteredProgress', () async {
      await navigator.push<void>(MaterialPageRoute(builder: (context) {
        return centeredProgressScreen();
      }));
    });
    item('CenteredProgress dark', () async {
      await navigator.push<void>(MaterialPageRoute(builder: (context) {
        return centeredProgressScreen(themeData: ThemeData.dark());
      }));
    });
    Widget smallIconsScreen({ThemeData? themeData}) {
      return Theme(
          data: themeData ?? ThemeData.light(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('App Widget'),
            ),
            body: Wrap(
              children: const [
                SmallProgress(),
                SmallConnectivityError(),
                Icon(Icons.email)
              ],
            ),
          ));
    }

    item('SmallIcons', () async {
      await navigator.push<void>(MaterialPageRoute(builder: (context) {
        return smallIconsScreen();
      }));
    });
    item('SmallIcons dark', () async {
      await navigator.push<void>(MaterialPageRoute(builder: (context) {
        return smallIconsScreen(themeData: ThemeData.dark());
      }));
    });
  });
}

void main() {
  platformInit();
  mainMenu(() {
    defineMenu();
  }, showConsole: true);
}
