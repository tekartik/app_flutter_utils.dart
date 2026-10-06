import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:tekartik_app_navigator_flutter/src/route_information_parser.dart';

class StartContentPath extends ContentPathBase {
  final start = ContentPathPart('start');

  @override
  List<ContentPathField> get fields => [start];
}

ContentPageDef _def(ContentPath path) =>
    ContentPageDef(path: path, screenBuilder: (_) => Container());

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
    test('parse unknown falls back to home', () async {
      var bloc = ContentNavigatorBloc(
        contentNavigator: ContentNavigator(
          def: ContentNavigatorDef(
            defs: [_def(rootContentPath), _def(StartContentPath())],
          ),
        ),
      );
      var crip = ContentRouteInformationParser(bloc);
      expect(
        await crip.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/start')),
        ),
        StartContentPath(),
      );
      // Unknown deep link such as https://host/privacy.html
      expect(
        await crip.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/privacy.html')),
        ),
        rootContentPath,
      );
      expect(
        await crip.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/start/other')),
        ),
        rootContentPath,
      );
    });
    test('home is the first def when there is no root', () async {
      var bloc = ContentNavigatorBloc(
        contentNavigator: ContentNavigator(
          def: ContentNavigatorDef(defs: [_def(StartContentPath())]),
        ),
      );
      var crip = ContentRouteInformationParser(bloc);
      expect(
        await crip.parseRouteInformation(
          RouteInformation(uri: Uri.parse('/unknown')),
        ),
        StartContentPath(),
      );
    });
  });
}
