import 'package:tekartik_firebase_firestore/firestore.dart';

FirestoreService get firestoreService => _stub('firestoreService');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
