import 'import.dart';

FirestoreService get firestoreService => _stub('firestoreService');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
