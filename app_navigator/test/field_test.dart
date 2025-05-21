import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:test/test.dart';

void main() {
  group('Field', () {
    test('equals', () {
      expect(ContentPathField('name'), ContentPathField('name'));
      expect(ContentPathField('name'), ContentPathField('name', null));
      expect(ContentPathField('name', '1'), ContentPathField('name', '1'));
      expect(
        ContentPathField('name', '1'),
        isNot(ContentPathField('name', '2')),
      );
      expect(ContentPathField('name'), isNot(ContentPathField('name2')));
      expect(ContentPathField('name'), isNot(ContentPathField('name', '1')));
    });

    test('fromField', () {
      expect(
        ContentPathField('name')..value = 'value',
        ContentPathField('name', 'value'),
      );
    });

    test('matchesField', () {
      expect(
        ContentPathField('test').matchesField(ContentPathField('test')),
        isTrue,
      );
      expect(
        ContentPathField(
          'test',
        ).matchesField(ContentPathField('test', 'value')),
        isTrue,
      );
      expect(
        ContentPathField(
          'test',
          'value',
        ).matchesField(ContentPathField('test', 'value')),
        isTrue,
      );
      expect(
        ContentPathField(
          'test',
          'value',
        ).matchesField(ContentPathField('test', 'other_value')),
        isFalse,
      );
      expect(
        ContentPathField('test').matchesField(ContentPathField('other')),
        isFalse,
      );
      expect(
        ContentPathPart('test').matchesField(ContentPathField('test')),
        isFalse,
      );
      expect(
        ContentPathPart('test').matchesField(ContentPathPart('test')),
        isTrue,
      );
    });

    test('noValue', () {
      var field = ContentPathField('my_name');
      expect(field.value, isNull);
      expect(field.name, 'my_name');
    });
    test('withValue', () {
      var field = ContentPathField('my_name', 'my_value');
      expect(field.value, 'my_value');
      expect(field.name, 'my_name');
    });
    test('isValid', () {
      var field = ContentPathField('my_name');
      expect(field.isValid(), isFalse);
      field.value = 'my_value';
      expect(field.isValid(), isTrue);
      var part = ContentPathPart('my_name');
      expect(part.isValid(), isTrue);
    });
  });
}
