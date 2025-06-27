import 'import.dart';

AuthService get authService => _stub('authService');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
