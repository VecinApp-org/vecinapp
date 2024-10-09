import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String text,
}) async {
  await showGenericDialog<void>(
      context: context,
      title: '¡Ah caray!',
      content: text,
      optionBuilder: () => {
            'OK': null,
          });
}
