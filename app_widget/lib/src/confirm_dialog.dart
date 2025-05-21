import 'package:flutter/material.dart';

/// A simple dialog button
class DialogButton extends StatelessWidget {
  /// Label of the button
  final String text;

  /// Callback when the button is pressed
  final VoidCallback onPressed;

  /// Whether the button is primary
  final bool isPrimary;

  /// Constructor
  const DialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Text(
          text,
          style: TextStyle(
            // color: isPrimary ? Colors.white : Colors.white,
            //fontSize: isPrimary ? 16 : 12,
            fontWeight: isPrimary ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

Future<bool> muiConfirm(
  BuildContext context, {
  String message = 'Confirm operation',
}) async {
  return await (showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(
              bottom: 16,
              left: 16,
              right: 16,
              top: 8,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: <Widget>[
              DialogButton(
                text: 'Yes',
                isPrimary: true,
                onPressed: () async {
                  Navigator.of(context).pop(true);
                },
              ),
              DialogButton(
                text: 'No',
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
      )) ??
      false;
}
