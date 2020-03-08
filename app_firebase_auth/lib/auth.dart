import 'package:tekartik_firebase_auth/auth.dart';

import 'src/firebase_auth.dart' as src;

export 'package:tekartik_firebase_auth/auth.dart';

/// Firebase application authService.
AuthService get authService => src.authService;

/// Google auth provider.
AuthProvider get googleAuthProvider => src.googleAuthProvider;
