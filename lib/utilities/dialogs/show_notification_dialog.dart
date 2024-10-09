import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/dialogs/generic_dialog.dart';

Future<void> showNotificationDialog({
  required BuildContext context,
  required String title,
  required String content,
}) async {
  await showGenericDialog<void>(
      context: context,
      title: title,
      content: content,
      optionBuilder: () => {
            'OK': null,
          });
}
