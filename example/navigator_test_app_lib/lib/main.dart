import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:tekartik_app_navigator_flutter/route_aware.dart';
import 'package:tekartik_test_menu_flutter/test.dart';

Future<void> main() async {
  mainMenuFlutter(() {
    defineNavigatorMenu();
  }, showConsole: true);
}

void defineNavigatorMenu() {
  menu('navigator', () {
    item('run app with navigator', () async {
      contentNavigatorDebug = true;
      runAppWithNavigator();
    });
  });
}

Future<void> _pushPage1(BuildContext context) async {
  var result = await ContentNavigator.of(
    muiBuildContext,
  ).pushPath<Object?>(Page1ContentPath());
  // ignore: use_build_context_synchronously
  await muiSnack(muiBuildContext, 'push Page 1 result: $result');
}

final pageStartDef = ContentPageDef(
  path: rootContentPath,
  screenBuilder: (_) {
    return muiScreenWidget('Start', () {
      muiItem('push Page 1', () async {
        await _pushPage1(muiBuildContext);
      });
      muiItem('push Page 2', () async {
        var result = await ContentNavigator.of(
          muiBuildContext,
        ).pushPath<Object?>(Page2ContentPath());
        // ignore: use_build_context_synchronously
        await muiSnack(muiBuildContext, 'push Page 2 result: $result');
      });
    });
  },
);
final page1Def = ContentPageDef(
  path: Page1ContentPath(),
  screenBuilder: (_) {
    return muiScreenWidget('Page 1', () {
      muiItem('push Page 2', () async {
        var result = await ContentNavigator.of(
          muiBuildContext,
        ).pushPath<Object?>(Page2ContentPath());
        // ignore: use_build_context_synchronously
        await muiSnack(muiBuildContext, 'push Page 2 result: $result');
      });
      muiItem('pop', () {
        Navigator.of(muiBuildContext).pop();
      });
    });
  },
);
var page2Def = ContentPageDef(
  path: Page2ContentPath(),
  screenBuilder: (_) {
    return muiScreenWidget('Page 2', () {
      muiItem('pop', () {
        Navigator.of(muiBuildContext).pop();
      });
      muiItem('pop to root', () {
        Navigator.of(muiBuildContext).popUntilPath(rootContentPath);
      });
      muiItem('pop all', () {
        ContentNavigator.of(muiBuildContext).transientPopAll();
      });
      muiItem('pop to root push page 1', () async {
        Navigator.of(muiBuildContext).popUntilPath(rootContentPath);
        await _pushPage1(muiBuildContext);
      });
      muiItem('pop all push page 1', () async {
        ContentNavigator.of(muiBuildContext).transientPopAll();
        await _pushPage1(muiBuildContext);
      });
      muiItem('popUntilPathOrPush page 1', () async {
        ContentNavigator.of(
          muiBuildContext,
        ).popUntilPathOrPush(muiBuildContext, Page1ContentPath());
      });
    });
  },
);

class Page1ContentPath extends ContentPathBase {
  final part = ContentPathPart('page1');

  @override
  List<ContentPathField> get fields => [part];
}

class Page2ContentPath extends ContentPathBase {
  final part = ContentPathPart('page2');

  @override
  List<ContentPathField> get fields => [part];
}

final contentNavigatorDef = ContentNavigatorDef(
  defs: [pageStartDef, page1Def, page2Def],
);

//var _contentNavigator =
void runAppWithNavigator() {
  runApp(
    ContentNavigator(
      observers: [routeAwareObserver],
      def: contentNavigatorDef,
      child: Builder(
        builder: (context) {
          var cn = ContentNavigator.of(context);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Navigator',
            //navigatorObservers: [cn.routeObserver],
            routerConfig: cn.routerConfig,
          );
        },
      ),
    ),
  );
}
