import 'import.dart';

Firebase get firebase => _stub('firebase');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
