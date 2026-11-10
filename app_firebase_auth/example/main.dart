// Anonymous sign in and sign out (FlutterFire setup done: `flutterfire
// configure`, or google-services.json / GoogleService-Info.plist, and the
// anonymous provider enabled in the Firebase console).
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_app_flutter_firebase_auth/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseAuth? auth;
  Object? error;
  try {
    var app = await firebase.initializeAppAsync();
    auth = authService.auth(app);
  } catch (e) {
    // No FlutterFire configuration (or Linux, not supported).
    error = e;
  }
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase auth')),
        body: auth == null
            ? Center(child: Text('Firebase not available: $error'))
            : AuthPage(auth: auth),
      ),
    ),
  );
}

/// Written against [FirebaseAuth]: a widget test passes a local auth
/// (tekartik_firebase_auth_local) instead.
class AuthPage extends StatelessWidget {
  /// The auth to use.
  final FirebaseAuth auth;

  /// Shows the current user and a sign in/out button.
  const AuthPage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser?>(
      stream: auth.onCurrentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // The session is being restored.
          return const Center(child: CircularProgressIndicator());
        }
        var user = snapshot.data;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(user == null ? 'Signed out' : 'Signed in: ${user.uid}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (user == null) {
                      await auth.signInAnonymously();
                    } else {
                      await auth.signOut();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                },
                child: Text(user == null ? 'Sign in anonymously' : 'Sign out'),
              ),
            ],
          ),
        );
      },
    );
  }
}
