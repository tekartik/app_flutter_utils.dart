import 'package:flutter/material.dart';

import 'confirm_dialog.dart';

/// Show a dialog to get a string
///
/// returns null on cancel
Future<int?> muiSelectString(
  BuildContext context, {
  double? width,

  /// initial value
  required List<String> list,
  String? title,
}) async {
  return await showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: (title != null) ? Text(title) : null,
        content: SizedBox(
          width: width ?? 800,
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                var text = list[index];
                return ListTile(
                  dense: true,
                  title: Text(text),
                  onTap: () {
                    Navigator.of(context).pop(index);
                  },
                );
              },
            ),
          ),
        ),
        actions: <Widget>[
          DialogButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            text: 'CANCEL',
          ),
        ],
      );
    },
  );
}
