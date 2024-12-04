import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/dialogs/generic_dialog.dart';

Future<bool> showConfirmationDialog(
    {required BuildContext context,
    required String text,
    bool isDestructive = false,
    String? title,
    String? confirmText}) {
  return showGenericDialog<bool>(
    context: context,
    isDestructiveAction: isDestructive,
    title: title ?? '¿De verdad?',
    content: text,
    optionBuilder: () => {
      confirmText ?? 'Confirmar': true,
    },
  ).then((value) => value ?? false);
}
