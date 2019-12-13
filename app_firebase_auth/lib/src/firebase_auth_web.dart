import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_auth_browser/auth_browser.dart';

AuthService get authService => authServiceBrowser;
AuthProvider get googleAuthProvider => GoogleAuthProvider();
