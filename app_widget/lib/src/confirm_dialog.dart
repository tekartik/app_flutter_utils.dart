import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const DialogButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Text(
          text,
          style: TextStyle(
              color: isPrimary ? Colors.white : Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

Future<bool> muiConfirm(BuildContext context,
    {String message = 'Confirm operation'}) async {
  return await (showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              actionsPadding: const EdgeInsets.only(
                  bottom: 16, left: 16, right: 16, top: 8),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Text(message,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              actions: <Widget>[
                DialogButton(
                    text: 'Yes',
                    isPrimary: true,
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                    }),
                DialogButton(
                  text: 'No',
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          })) ??
      false;
}
