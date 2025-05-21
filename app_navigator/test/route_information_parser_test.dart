import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:tekartik_app_navigator_flutter/src/route_information_parser.dart';

void main() {
  group('ContentRouteInformationParser', () {
    test('restore', () {
      var bloc = ContentNavigatorBloc();
      var crip = ContentRouteInformationParser(bloc);
      expect(crip.restoreRouteInformation(rootContentPath).uri.toString(), '/');
      expect(
        crip
            .restoreRouteInformation(ContentPath([ContentPathPart('test')]))
            .uri
            .toString(),
        '/test',
      );
    });
    test('parse', () {
      var bloc = ContentNavigatorBloc();
      var crip = ContentRouteInformationParser(bloc);
      expect(
        crip.parseAnyRouteInformationSync(
          RouteInformation(uri: Uri.parse('/')),
        ),
        rootContentPath,
      );
      expect(
        crip.parseAnyRouteInformationSync(
          RouteInformation(uri: Uri.parse('/test')),
        ),
        ContentPath([ContentPathPart('test')]),
      );
    });
  });
}
