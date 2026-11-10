// Initializes Firebase with the platform default options (FlutterFire setup
// done: `flutterfire configure`, or google-services.json /
// GoogleService-Info.plist) and shows the project id.
import 'package:flutter/widgets.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';

/// Written against the [Firebase] interface: a unit test passes
/// `newFirebaseMemory()` (tekartik_firebase_local) instead.
Future<FirebaseApp> initFirebase(Firebase firebase) async {
  return await firebase.initializeAppAsync();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String text;
  try {
    var app = await initFirebase(firebase);
    text = 'Project ${app.projectId}';
  } catch (e) {
    // No FlutterFire configuration (or Linux, not supported).
    text = 'Firebase not available: $e';
  }
  runApp(Center(child: Text(text, textDirection: TextDirection.ltr)));
}
