import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:tekartik_app_navigator_flutter/src/route_information_parser.dart';

class StartContentPath extends ContentPathBase {
  final start = ContentPathPart('start');

  @override
  List<ContentPathField> get fields => [start];
}

class NoteContentPath extends ContentPathBase {
  final note = ContentPathField('note');

  @override
  List<ContentPathField> get fields => [note];
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
    test('url round trip of path values', () async {
      var bloc = ContentNavigatorBloc(
        contentNavigator: ContentNavigator(
          def: ContentNavigatorDef(
            defs: [_def(rootContentPath), _def(NoteContentPath())],
          ),
        ),
      );
      var crip = ContentRouteInformationParser(bloc);
      Future<ContentPath> reload(Uri uri) => crip.parseRouteInformation(
        // As the browser gives it back (reload, back, shared link).
        RouteInformation(uri: Uri.parse(uri.toString())),
      );
      for (var id in [
        'x1',
        'Café Tacvba',
        'a b',
        'a?b',
        'a#b',
        '50%',
        'a%20b',
        'a/b',
      ]) {
        var path = NoteContentPath()..note.value = id;
        var uri = crip.restoreRouteInformation(path).uri;
        var parsed = await reload(uri);
        expect(parsed.field('note')?.value, id, reason: '$id: $uri');
        expect(NoteContentPath()..fromPath(parsed), path);
      }
      // Plain values stay readable.
      expect(
        crip
            .restoreRouteInformation(NoteContentPath()..note.value = 'x1')
            .uri
            .toString(),
        '/note/x1',
      );
      // A percent-encoded deep link.
      expect(
        (await reload(Uri.parse('/note/Caf%C3%A9'))).field('note')?.value,
        'Café',
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
