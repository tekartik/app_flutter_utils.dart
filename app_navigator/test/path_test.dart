import 'package:tekartik_app_navigator_flutter/content_navigator.dart';
import 'package:test/test.dart';

class SchoolStudentPath extends ContentPathBase {
  final school = ContentPathField('school');
  final student = ContentPathField('student');

  @override
  List<ContentPathField> get fields => [school, student];
}

class SimplePath extends ContentPathBase {
  final section = ContentPathField('section');

  @override
  List<ContentPathField> get fields => [section];
}

class BasePath extends ContentPathBase {
  final base = ContentPathField('base');

  @override
  List<ContentPathField> get fields => [base];
}

class SubPath extends BasePath {
  final sub = ContentPathPart('sub');

  @override
  List<ContentPathField> get fields => [base, sub];
}

void main() {
  group('Path', () {
    test('fromString', () {
      var path = ContentPath.fromString('/');
      expect(path.fields, isEmpty);
      path = ContentPath.fromString('/');
      expect(path.fields, isEmpty);
      path = ContentPath.fromString('//');
      expect(path.fields, isEmpty);
      path = ContentPath.fromString('/test');
      expect(path.fields, [ContentPathPart('test')]);
      expect(path.fields, isNot([ContentPathField('test')]));
      path = ContentPath.fromString('/test/');
      expect(path.fields, [ContentPathPart('test')]);
      path = ContentPath.fromString('/test');
      expect(path.fields, [ContentPathPart('test')]);
      path = ContentPath.fromString('test');
      expect(path.fields, [ContentPathPart('test')]);
      path = ContentPath.fromString('/test/1');
      expect(path.fields, [ContentPathField('test', '1')]);
      path = ContentPath.fromString('/test/*');
      expect(path.fields, [ContentPathField('test', '*')]);
      path = ContentPath.fromString('/test/*');
      expect(path.fields, [ContentPathField('test', null)]);
      path = ContentPath.fromString('/test/1/sub');
      expect(path.fields, [
        ContentPathField('test', '1'),
        ContentPathPart('sub'),
      ]);
      path = ContentPath.fromString('test/1/sub/2');
      expect(path.fields, [
        ContentPathField('test', '1'),
        ContentPathField('sub', '2'),
      ]);

      // set status
      path = ContentPath.fromString('test');
      expect(path.fields.first.value, '');
      expect(path.fields.first.name, 'test');
    });
    test('toPath', () {
      String rt(String path) {
        return ContentPath.fromString(path).toPathString();
      }

      expect(rt('//'), '/');
      expect(rt(''), '/');
      expect(rt('/'), '/');
      expect(rt('/test/*'), '/test/*');
      expect(rt('/test/'), '/test');
      expect(rt('test/1/sub/2'), '/test/1/sub/2');

      var object = SchoolStudentPath()
        ..student.value = '124'
        ..school.value = 'the_school';
      expect(object.toPathString(), '/school/the_school/student/124');

      object = SchoolStudentPath();
      expect(object.toPathString(), '/school/*/student/*');
    });

    test('Path.toPath', () {
      var simple = SimplePath();
      expect(simple.toPathString(), '/section/*');
      //simple.section.setNull();
      //expect(simple.toPath(), 'section');
      //simple.section.clear();
      //expect(simple.toPath(), 'section/*');
      simple.section.value = '123';
      expect(simple.toPathString(), '/section/123');

      var object = SchoolStudentPath();
      expect(object.toPathString(), '/school/*/student/*');
      //object.student.setNull();
      expect(object.toPathString(), '/school/*/student/*');
    });

    test('toMap', () {
      Map<String?, String?> rt(String path) {
        return ContentPath.fromString(path).toStringMap();
      }

      expect(rt('/'), isEmpty);
      // expect(rt('/test/'), {'test': null});
      expect(rt('/test/'), {'test': ''});
      expect(rt('/test/1'), {'test': '1'});
      expect(rt('test/1/sub/2'), {'test': '1', 'sub': '2'});
    });

    test('matches', () {
      var simple1 = SimplePath();
      var simple2 = SimplePath();
      expect(simple1.matchesPath(simple2), isTrue);
      simple2.section.value = 'any';
      expect(simple1.matchesPath(simple2), isTrue);
      simple1.section.value = 'other';
      expect(simple1.matchesPath(simple2), isFalse);
      /*
      expect(simple1.matchesPath(simple2), isFalse);
      simple1.section.value = 'any';
      expect(simple1.matchesPath(simple2), isTrue);
      simple2.section.value = null;
      expect(simple1.matchesPath(simple2), isTrue);
      */
      expect(
        ContentPath.fromString(
          'test/*/sub/*',
        ).matchesPath(ContentPath.fromString('test/34/sub/28')),
        isTrue,
      );
      expect(
        ContentPath.fromString(
          'test/1/sub/2',
        ).matchesPath(ContentPath.fromString('test/34/dub/28')),
        isFalse,
      );
      expect(
        ContentPath.fromString(
          'test/1',
        ).matchesPath(ContentPath.fromString('test')),
        isFalse,
      );
      expect(
        ContentPath.fromString(
          '/test/1',
        ).matchesPath(ContentPath.fromString('test/1')),
        isTrue,
      );
      expect(
        ContentPath.fromString(
          'test/1',
        ).matchesPath(ContentPath.fromString('/test/1')),
        isTrue,
      );
      expect(
        ContentPath.fromString(
          'test/1',
        ).matchesPath(ContentPath.fromString('test/2')),
        isFalse,
      );

      expect(
        ContentPath.fromString('').matchesPath(ContentPath.fromString('')),
        isTrue,
      );
    });

    test('startsWith', () {
      expect(SubPath().startsWith(BasePath()), isTrue);
      expect(BasePath().startsWith(SubPath()), isFalse);
      expect(SubPath().startsWith(SubPath()), isTrue);
      expect(BasePath().startsWith(BasePath()), isTrue);
    });
    test('fromPath', () {
      var object = SchoolStudentPath()
        ..fromPath(ContentPath.fromString('school/the_school/student/124'));
      expect(object.toPathString(), '/school/the_school/student/124');
      expect(
        object.toString(),
        'SchoolStudentPath(/school/the_school/student/124)',
      );

      object = SchoolStudentPath()
        ..fromPath(ContentPath.fromString('/school/the_school/student/124'));
      expect(object.toPathString(), '/school/the_school/student/124');
      expect(
        object.toString(),
        'SchoolStudentPath(/school/the_school/student/124)',
      );

      object = SchoolStudentPath()
        ..fromPath(ContentPath.fromString('school/the_school/student'));
      expect(object.toPathString(), '/school/the_school/student');

      var boxCp = BoxAddObservationContentPath()
        ..fromPath(ContentPath.fromString('/category/my_cat/action'));
      expect(boxCp.categoryId.value, 'my_cat');
      expect(boxCp.action.value, '');
      expect(boxCp.toPathString(), '/category/my_cat/action');
    });

    test('root', () {
      expect(rootContentPathString, '/');
      expect(rootContentPath.matchesString('/'), isTrue);
      expect(rootContentPath.matchesString('//'), isTrue);
      expect(rootContentPath.matchesString(''), isTrue);
      expect(rootContentPath.matchesString('a'), isFalse);
      expect(rootContentPath.matchesString('/a'), isFalse);
    });
    test('isValid', () {
      expect(SubPath().isValid(), isFalse);
      expect((SubPath()..base.value = '123').isValid(), isTrue);
    });
  });
}

// /category/1234
class CategoryContentPath extends ContentPathBase {
  final categoryId = ContentPathField('category');

  @override
  List<ContentPathField> get fields => [categoryId];
}

// /category/1234/action
class BoxAddObservationContentPath extends CategoryContentPath {
  final action = ContentPathPart('action');

  @override
  List<ContentPathField> get fields => [...super.fields, action];
}
