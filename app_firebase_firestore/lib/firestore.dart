import 'src/firestore.dart' as src;
import 'src/import.dart';

// ignore: depend_on_referenced_packages
export 'package:tekartik_firebase_firestore/firestore.dart';

/// Firestore service to use in the app.
FirestoreService get firestoreService => src.firestoreService;
