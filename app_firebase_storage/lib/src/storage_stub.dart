import 'package:tekartik_firebase_storage/storage.dart';

StorageService get storageService => _stub('storageService');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
