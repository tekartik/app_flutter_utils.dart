import 'package:flutter/material.dart';

Future<void> muiSnack(BuildContext context, String message) async {
  muiSnackSync(context, message);
}

/// Hide existing snack and show new one
void muiSnackSync(BuildContext context, String message) {
  // ignore: avoid_print
  print('snack: $message');
  if (context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
