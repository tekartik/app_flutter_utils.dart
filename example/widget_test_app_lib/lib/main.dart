import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/app_widget.dart';
import 'package:tekartik_app_flutter_widget/delayed_display.dart';
import 'package:tekartik_app_flutter_widget/view/all_widget_for_theming.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_test_menu_flutter/test.dart';
import 'package:tekartik_test_menu_flutter/test_menu_flutter.dart';
import 'package:tekartik_widget_test_app_lib/cv_ui_menu.dart';
import 'package:tekartik_widget_test_app_lib/mini_ui_test_menu.dart';
import 'package:tekartik_widget_test_app_lib/scroll_behavior_menu.dart';
import 'package:tekartik_widget_test_app_lib/will_pop_scope_compat_menu.dart';

void defineMenu() {
  menuWillPopScopeCompat();
  menuMinuUi();
  menuAppScrollBehavior();
  menuCvUi();
  menu('widget', () {
    //devPrint('MAIN_');
    Widget centeredProgressScreen({ThemeData? themeData}) {
      return Theme(
        data: themeData ?? ThemeData.light(),
        child: Scaffold(
          appBar: AppBar(title: const Text('App Widget')),
          body: const CenteredProgress(),
        ),
      );
    }

    item('CenteredProgress', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            return centeredProgressScreen();
          },
        ),
      );
    });
    item('CenteredProgress dark', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            return centeredProgressScreen(themeData: ThemeData.dark());
          },
        ),
      );
    });
    Widget allWidgetForThemingScreen({ThemeData? themeData}) {
      return Theme(
        data: themeData ?? ThemeData.light(),
        child: Scaffold(
          appBar: AppBar(title: const Text('App Widget')),
          body: const SingleChildScrollView(child: AllWidgetForTheming()),
        ),
      );
    }

    item('AllWidgetForTheming', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            return allWidgetForThemingScreen();
          },
        ),
      );
    });
    item('AllWidgetForTheming dark', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            return allWidgetForThemingScreen(themeData: ThemeData.dark());
          },
        ),
      );
    });
    Widget smallIconsScreen({ThemeData? themeData}) {
      return Theme(
        data: themeData ?? ThemeData.light(),
        child: Scaffold(
          appBar: AppBar(title: const Text('App Widget')),
          body: const Wrap(
            children: [
              SmallProgress(),
              SmallConnectivityError(),
              Icon(Icons.email),
            ],
          ),
        ),
      );
    }

    item('SmallIcons', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            return smallIconsScreen();
          },
        ),
      );
    });
    item('SmallIcons dark', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            return smallIconsScreen(themeData: ThemeData.dark());
          },
        ),
      );
    });
    item('Delayed Display dark', () async {
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(title: const Text('Delayed display')),
              body: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DelayedDisplay(
                      child: Text('DEMO', style: TextStyle(fontSize: 32)),
                    ),
                    DelayedDisplay(
                      delay: Duration(milliseconds: 2000),
                      child: Text(
                        'DEMO delay 2000',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                    DelayedDisplay(
                      fadingDuration: Duration(milliseconds: 2000),
                      child: Text(
                        'DEMO fading 2000',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                    DelayedDisplay(
                      slidingBeginOffset: Offset(-32.0, -32.0),
                      child: Text(
                        'DEMO left, top 32',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  });
}

void main() {
  platformInit();
  mainMenuFlutter(() {
    defineMenu();
  }, showConsole: true);
}
