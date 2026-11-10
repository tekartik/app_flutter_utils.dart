// A home page listing notes, a note page (`/note/<id>`) returning a result.
// On the web the url follows the pages: /note/2 opens note 2 on reload.
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_navigator_flutter/content_navigator.dart';

/// `/note/<id>`, a wildcard id in the page definition.
class NotePath extends ContentPathBase {
  /// The note id field.
  final note = ContentPathField('note');

  @override
  List<ContentPathField> get fields => [note];

  /// The definition path (any id).
  NotePath();

  /// The path of note [id].
  NotePath.id(String id) {
    note.value = id;
  }
}

/// The page definitions, the root first (the initial page).
final appDef = ContentNavigatorDef(
  defs: [
    ContentPageDef(
      path: rootContentPath,
      screenBuilder: (_) => const HomePage(),
    ),
    ContentPageDef(
      path: NotePath(),
      screenBuilder: (rs) {
        var path = NotePath()..fromPath(rs.path);
        return NotePage(id: path.note.value!);
      },
    ),
  ],
);

void main() {
  runApp(const NotesApp());
}

/// The app: the content navigator above `MaterialApp.router`.
class NotesApp extends StatelessWidget {
  /// The app.
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentNavigator(
      def: appDef,
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: 'Notes',
          routerConfig: ContentNavigator.of(context).routerConfig,
        ),
      ),
    );
  }
}

/// The list of notes.
class HomePage extends StatefulWidget {
  /// The list of notes.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _lastResult;

  Future<void> _open(String id) async {
    // Completes with the result the note page pops.
    var result = await ContentNavigator.pushPath<String>(
      context,
      NotePath.id(id),
    );
    if (mounted) {
      setState(() => _lastResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: ListView(
        children: [
          for (var id in ['1', '2', 'café au lait'])
            ListTile(title: Text('Note $id'), onTap: () => _open(id)),
          if (_lastResult != null) ListTile(title: Text('Back: $_lastResult')),
        ],
      ),
    );
  }
}

/// One note.
class NotePage extends StatelessWidget {
  /// The note id.
  final String id;

  /// One note.
  const NotePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Note $id')),
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).pop('read $id'),
          child: const Text('Mark as read'),
        ),
      ),
    );
  }
}
