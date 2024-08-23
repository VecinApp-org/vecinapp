import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('¡Ah caray!'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
