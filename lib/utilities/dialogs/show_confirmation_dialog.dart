import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/dialogs/generic_dialog.dart';

Future<bool> showConfirmationDialog(
    {required BuildContext context, required String text}) {
  return showGenericDialog<bool>(
    context: context,
    title: '¿De verdad?',
    content: text,
    optionBuilder: () => {
      'Cancelar': false,
      'Confirmar': true,
    },
  ).then((value) => value ?? false);
}
