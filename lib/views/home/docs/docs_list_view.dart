import 'package:flutter/material.dart';
import 'package:vecinapp/services/crud/docs_service.dart';
import 'package:vecinapp/utilities/show_confirmation_dialog.dart';

typedef DeleteDocCallback = void Function(DatabaseDoc doc);

class DocsListView extends StatelessWidget {
  final List<DatabaseDoc> docs;
  final DeleteDocCallback onDeleteDoc;

  const DocsListView({
    super.key,
    required this.docs,
    required this.onDeleteDoc,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          return ListTile(
            title: Text(
              doc.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final shouldDelete = await showConfirmationDialog(
                    context, '¿Quieres eliminar el documento?');
                if (shouldDelete == true) {
                  onDeleteDoc(doc);
                }
              },
            ),
          );
        });
  }
}
