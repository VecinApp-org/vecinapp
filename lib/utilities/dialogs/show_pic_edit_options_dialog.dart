import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/dialogs/generic_dialog.dart';

Future<String?> showPicEditOptionsDialog(
    {required BuildContext context, required String text}) {
  return showGenericDialog<String>(
    context: context,
    title: 'Editar imagen',
    content: text,
    optionBuilder: () => {
      'Cambiar': 'cambiar',
      'Eliminar': 'eliminar',
    },
  ).then((value) => value);
}
