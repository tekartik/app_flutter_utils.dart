import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

void main() {
  group('ContentRouteInformationParser', () {
    test('restore', () {
      var bloc = ContentNavigatorBloc();
      var crip = ContentRouteInformationParser(bloc);
      expect(crip.restoreRouteInformation(HomeContentPath()).location, '/');
      expect(
          crip
              .restoreRouteInformation(ContentPath([ContentPathPart('test')]))
              .location,
          '/test');
    });
    test('parse', () {
      var bloc = ContentNavigatorBloc();
      var crip = ContentRouteInformationParser(bloc);
      expect(
          crip.parseAnyRouteInformationSync(
              const RouteInformation(location: '/')),
          homeContentPath);
      expect(
          crip.parseAnyRouteInformationSync(
              const RouteInformation(location: '/test')),
          ContentPath([ContentPathPart('test')]));
    });
  });
}
