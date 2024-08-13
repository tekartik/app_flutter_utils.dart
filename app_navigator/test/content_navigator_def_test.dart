import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

class StartContentPath extends ContentPathBase {
  final start = ContentPathPart('start');

  @override
  List<ContentPathField> get fields => [start];
}

void main() {
  var startDef = ContentPageDef(
      path: StartContentPath(), screenBuilder: (_) => Container());

  group('ContentNavigatorDef', () {
    test('find', () {
      var def = ContentNavigatorDef(defs: [startDef]);
      expect(def.findPageDef(StartContentPath()), startDef);
    });
  });
}
