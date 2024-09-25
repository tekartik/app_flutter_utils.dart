import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';

AuthService get authService => authServiceFlutter;

AuthProvider get googleAuthProvider => _stub('googleAuthProvider');

T _stub<T>(String message) {
  throw UnimplementedError(message);
}
