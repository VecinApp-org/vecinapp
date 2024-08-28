import 'package:flutter/material.dart';
import 'package:vecinapp/services/cloud/cloud_doc.dart';
import 'package:vecinapp/services/cloud/firebase_cloud_storage.dart';
import 'package:vecinapp/utilities/show_confirmation_dialog.dart';
import 'package:vecinapp/views/home/docs/edit_doc_view.dart';

class DocDetailsView extends StatefulWidget {
  const DocDetailsView({super.key, required this.doc});
  final CloudDoc doc;

  @override
  State<DocDetailsView> createState() => _DocDetailsViewState();
}

class _DocDetailsViewState extends State<DocDetailsView> {
  final _docsService = FirebaseCloudStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<EditOrDelete>(
            onSelected: (value) async {
              switch (value) {
                case EditOrDelete.edit:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditDocView(doc: widget.doc),
                    ),
                  );
                case EditOrDelete.delete:
                  final shouldDelete = await showConfirmationDialog(
                      context, '¿Eliminar el documento?');
                  if (shouldDelete == true) {
                    await _docsService.deleteDoc(
                        documentId: widget.doc.documentId);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
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
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(32.0),
        children: [
          Text(
            widget.doc.title,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 32),
          Text(widget.doc.text),
        ],
      ),
    );
  }
}

enum EditOrDelete {
  edit,
  delete,
}
