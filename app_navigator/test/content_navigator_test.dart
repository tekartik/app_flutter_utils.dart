import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

var homePageDef = ContentPageDef(
  screenBuilder: (_) {
    return const Text('home');
  },
  path: rootContentPath,
);

final contentNavigatorDef = ContentNavigatorDef(defs: [homePageDef]);

void main() {
  group('content_navigator', () {
    testWidgets('initial_route', (WidgetTester tester) async {
      contentNavigatorDebug = true;
      await tester.pumpWidget(
        ContentNavigator(
          def: contentNavigatorDef,
          child: Builder(
            builder: (context) {
              var cn = ContentNavigator.of(context);
              return MaterialApp.router(
                title: 'Stable app',
                routerDelegate: cn.routerDelegate,
                routeInformationParser: cn.routeInformationParser,
                // routeInformationProvider: _platformRouteInformationProvider, // if uncomment we always start on the initial route
              );
            },
          ),
        ),
      );
      expect(find.text('home'), findsOneWidget);
    });
    testWidgets('unknown_route_shows_home', (WidgetTester tester) async {
      await tester.pumpWidget(
        ContentNavigator(
          def: contentNavigatorDef,
          child: Builder(
            builder: (context) {
              var cn = ContentNavigator.of(context);
              return MaterialApp.router(
                routerDelegate: cn.routerDelegate,
                routeInformationParser: cn.routeInformationParser,
                routeInformationProvider: PlatformRouteInformationProvider(
                  initialRouteInformation: RouteInformation(
                    uri: Uri.parse('/privacy.html'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      expect(find.text('home'), findsOneWidget);
    });
  });
}
