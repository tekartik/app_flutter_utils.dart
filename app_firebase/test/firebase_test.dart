import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';

void main() {
  group('app_firebase', () {
    test('api', () {
      // ignore: unnecessary_statements
      Firebase;
      try {
        firebase;
      } catch (_) {}
    });
  });
}
