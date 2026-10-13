import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

void main() {
  test('ContentPathField and ContentPath hashCode consistent with ==', () {
    var field1 = ContentPathField('note', '1');
    var field2 = ContentPathField('note', '1');
    expect(field1, field2);
    expect(field1.hashCode, field2.hashCode);
    expect({field1}.contains(field2), isTrue);

    var path1 = ContentPath.fromString('/note/1');
    var path2 = ContentPath.fromString('/note/1');
    expect(path1, path2);
    expect(path1.hashCode, path2.hashCode);
    expect({path1}.contains(path2), isTrue);
    expect({path1}.contains(ContentPath.fromString('/note/2')), isFalse);
  });
}
