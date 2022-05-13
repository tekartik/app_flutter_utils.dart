import 'import.dart';

AuthService get authService => _stub('authService');

AuthProvider get googleAuthProvider => _stub('googleAuthProvider');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
