// A live list of the documents of the `notes` collection and a button adding
// one (FlutterFire setup done: `flutterfire configure`, or
// google-services.json / GoogleService-Info.plist, and Firestore rules
// allowing it).
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_firebase/firebase.dart';
import 'package:tekartik_app_flutter_firebase_firestore/firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore? firestore;
  Object? error;
  try {
    var app = await firebase.initializeAppAsync();
    firestore = firestoreService.firestore(app);
  } catch (e) {
    // No FlutterFire configuration (or Linux, not supported).
    error = e;
  }
  runApp(
    MaterialApp(
      home: firestore == null
          ? Scaffold(
              body: Center(child: Text('Firebase not available: $error')),
            )
          : NotesPage(firestore: firestore),
    ),
  );
}

/// Written against [Firestore]: a widget test passes an in-memory one
/// (tekartik_firebase_firestore_sembast) instead.
class NotesPage extends StatelessWidget {
  /// The firestore to use.
  final Firestore firestore;

  /// The notes, newest first.
  const NotesPage({super.key, required this.firestore});

  CollectionReference get _notes => firestore.collection('notes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notes.orderBy('created', descending: true).onSnapshot(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          var docs = snapshot.data?.docs;
          if (docs == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: [
              for (var doc in docs)
                ListTile(
                  title: Text('${doc.data['title']}'),
                  subtitle: Text(doc.ref.id),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _notes.add({
          'title': 'Note ${DateTime.now().toIso8601String()}',
          'created': FieldValue.serverTimestamp,
        }),
        child: const Icon(Icons.add),
      ),
    );
  }
}
