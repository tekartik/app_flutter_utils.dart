// A dev menu built with mini_ui: dialogs, a cv model editor, back veto.
import 'package:cv/cv.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_flutter_widget/view/cv_ui.dart';
import 'package:tekartik_app_flutter_widget/will_pop_scope_compat.dart';

/// The model edited by the cv ui screen.
class Note extends CvModelBase {
  final title = CvField<String>('title');
  final tags = CvListField<String>('tags');

  @override
  CvFields get fields => [title, tags];
}

/// The dev menu: one tile per item, a sub menu pushes a new screen.
Widget demoMenu() => muiScreenWidget('demo', () {
  muiItem('Ask a name', () async {
    var context = muiBuildContext;
    var name = await muiGetString(
      context,
      title: 'Your name',
      validator: (value) => (value ?? '').isEmpty ? 'Required' : null,
    );
    if (name != null && context.mounted) {
      muiSnackSync(context, 'Hello $name');
    }
  });
  muiItem('Pick a color', () async {
    var context = muiBuildContext;
    var colors = ['red', 'green', 'blue'];
    var index = await muiSelectString(context, list: colors, title: 'Color');
    if (index != null && context.mounted) {
      muiSnackSync(context, 'Picked ${colors[index]}');
    }
  });
  muiItem('Edit a note', () async {
    var note = Note()
      ..title.v = 'Groceries'
      ..tags.v = ['home'];
    await Navigator.of(
      muiBuildContext,
    ).push<void>(MaterialPageRoute(builder: (_) => NoteEditScreen(note: note)));
  });
  muiMenu('More', () {
    muiItem('Confirm', () async {
      var context = muiBuildContext;
      var ok = await muiConfirm(context, message: 'Really?');
      if (context.mounted) {
        muiSnackSync(context, ok ? 'yes' : 'no');
      }
    });
  });
});

/// Edits a [note] in place, asks before leaving.
class NoteEditScreen extends StatefulWidget {
  /// The note edited.
  final Note note;

  /// Edits [note].
  const NoteEditScreen({super.key, required this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final _controller = CvUiModelEditController(model: widget.note);

  @override
  Widget build(BuildContext context) {
    return WillPopScopeCompat(
      // Back is vetoed until the user confirms.
      onWillPop: () => muiConfirm(context, message: 'Leave the editor?'),
      child: Scaffold(
        appBar: AppBar(title: const Text('Note')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [CvUiModelEdit(controller: _controller)],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: demoMenu()));
}
