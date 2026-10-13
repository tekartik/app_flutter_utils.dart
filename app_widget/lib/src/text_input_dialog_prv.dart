import 'package:material_ui/material_ui.dart';

import 'confirm_dialog.dart';

/// Text input dialog owning its text controller.
///
/// The controller lives as long as the dialog: a dialog still animating out
/// while the next one opens keeps its own (a shared controller disposed by the
/// next dialog would assert).
class TextInputDialogPrv<T> extends StatefulWidget {
  /// Optional title.
  final String? title;

  /// Initial value.
  final String? value;

  /// Optional hint.
  final String? hint;

  /// Optional validator.
  final FormFieldValidator<String>? validator;

  /// Result popped when OK is pressed with valid text.
  final T Function(String text) okResult;

  /// Actions after OK.
  final List<Widget> actions;

  /// Text input dialog owning its text controller.
  const TextInputDialogPrv({
    super.key,
    this.title,
    this.value,
    this.hint,
    this.validator,
    required this.okResult,
    required this.actions,
  });

  @override
  State<TextInputDialogPrv<T>> createState() => _TextInputDialogPrvState<T>();
}

class _TextInputDialogPrvState<T> extends State<TextInputDialogPrv<T>> {
  late final _textFieldController = TextEditingController(text: widget.value);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var title = widget.title;
    return AlertDialog(
      title: (title != null) ? Text(title) : null,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _textFieldController,
          decoration: InputDecoration(hintText: widget.hint),
          validator: widget.validator,
        ),
      ),
      actions: <Widget>[
        DialogButton(
          onPressed: () {
            _formKey.currentState!.save();
            if (_formKey.currentState!.validate()) {
              Navigator.of(context)
                  .pop(widget.okResult(_textFieldController.text));
            }
          },
          text: 'OK',
        ),
        ...widget.actions,
      ],
    );
  }
}

/// Dialog button popping null.
class TextInputDialogCancelButtonPrv extends StatelessWidget {
  /// Dialog button popping null.
  const TextInputDialogCancelButtonPrv({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      text: 'CANCEL',
    );
  }
}
