// ignore: provide_deprecation_message
@Deprecated('No more updated, please remove')
library tekartik_firebase_auth_web_deprecated;

import 'package:tekartik_firebase_auth_browser/auth_browser.dart';

import 'import.dart';

AuthService get authService => authServiceBrowser;

AuthProvider get googleAuthProvider => GoogleAuthProvider();
