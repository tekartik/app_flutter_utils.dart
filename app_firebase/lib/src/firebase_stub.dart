import 'package:tekartik_firebase/firebase.dart';

Firebase get firebase => _stub('firebase');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
