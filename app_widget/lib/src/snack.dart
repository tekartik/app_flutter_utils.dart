import 'package:flutter/material.dart';

Future<void> muiSnack(BuildContext context, String message) async {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
    ));
}
