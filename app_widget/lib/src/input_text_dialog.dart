import 'package:material_ui/material_ui.dart';

import 'text_input_dialog_prv.dart';

/// Show a dialog to get a string
///
/// returns null on cancel
Future<String?> muiGetString(
  BuildContext context, {

  /// initial value
  String? value,
  String? title,
  FormFieldValidator<String>? validator,
  String? hint,
}) async {
  return await showDialog<String>(
    context: context,
    builder: (context) => TextInputDialogPrv<String>(
      title: title,
      value: value,
      hint: hint,
      validator: validator,
      okResult: (text) => text,
      actions: const [TextInputDialogCancelButtonPrv()],
    ),
  );
}
