import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:test/test.dart';

class StartContentPath extends ContentPathBase {
  final start = ContentPathPart('start');

  @override
  List<ContentPathField> get fields => [start];
}

void main() {
  var startDef = ContentPageDef(path: StartContentPath(), screenBuilder: null);

  group('ContentNavigatorDef', () {
    test('find', () {
      var def = ContentNavigatorDef(defs: [startDef]);
      expect(def.findPageDef(StartContentPath()), startDef);
    });
  });
}
