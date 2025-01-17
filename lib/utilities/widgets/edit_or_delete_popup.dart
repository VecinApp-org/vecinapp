import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/dialogs/show_confirmation_dialog.dart';

class EditOrDeletePopupMenuIcon extends StatelessWidget {
  const EditOrDeletePopupMenuIcon({
    super.key,
    required this.editAction,
    required this.deleteAction,
  });

  final VoidCallback editAction;
  final VoidCallback deleteAction;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<EditOrDelete>(
      onSelected: (value) async {
        switch (value) {
          case EditOrDelete.edit:
            editAction();
          case EditOrDelete.delete:
            final shouldDelete = await showConfirmationDialog(
                context: context, text: '¿Eliminar?');
            if (shouldDelete && context.mounted) {
              deleteAction();
            }
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<EditOrDelete>(
            value: EditOrDelete.edit,
            child: Text('Editar'),
          ),
          const PopupMenuItem<EditOrDelete>(
            value: EditOrDelete.delete,
            child: Text('Eliminar'),
          )
        ];
      },
    );
  }
}

enum EditOrDelete {
  edit,
  delete,
}
