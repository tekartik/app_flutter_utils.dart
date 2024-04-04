import 'package:flutter/material.dart';

Future<void> muiSnack(BuildContext context, String message) async {
  // ignore: avoid_print
  print('snack: $message');
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
    ));
}
