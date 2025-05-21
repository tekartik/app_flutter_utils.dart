import 'package:flutter_test/flutter_test.dart';
import 'package:tekartik_app_flutter_firebase_storage/storage_utils.dart';

void main() {
  group('storage_utils', () {
    test('firebaseStorageGetAdminWebUploadFolder', () {
      expect(
        firebaseStorageGetAdminWebUploadFolder('1', '2', '3'),
        'https://console.firebase.google.com/project/1/storage/2/files/3',
      );
    });
  });
}
