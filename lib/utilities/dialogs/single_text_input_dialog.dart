import 'package:flutter/material.dart';

Future<String?> showTextInputDialog({
  required BuildContext context,
  required String title,
  required String labelText,
  required String? initialValue,
  String? text,
}) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text ?? ''),
            SizedBox(height: 16),
            TextField(
              autofocus: true,
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
            child: const Text('Aceptar'),
          ),
        ],
      );
    },
  );
}
