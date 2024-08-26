import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog<bool>(BuildContext context, String text) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirma la acción'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
}
