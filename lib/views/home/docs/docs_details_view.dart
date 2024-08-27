import 'package:flutter/material.dart';
import 'package:vecinapp/services/crud/docs_service.dart';
import 'package:vecinapp/utilities/show_confirmation_dialog.dart';

class DocDetailsView extends StatefulWidget {
  const DocDetailsView({super.key, required this.doc});
  final DatabaseDoc doc;

  @override
  State<DocDetailsView> createState() => _DocDetailsViewState();
}

class _DocDetailsViewState extends State<DocDetailsView> {
  final DocsService _docsService = DocsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
          PopupMenuButton<DocDetailsViewAction>(
            onSelected: (value) async {
              if (value == DocDetailsViewAction.delete) {
                final shouldDelete = await showConfirmationDialog(
                    context, '¿Quieres eliminar el documento?');
                if (shouldDelete == true) {
                  await _docsService.deleteDoc(id: widget.doc.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<DocDetailsViewAction>(
                  value: DocDetailsViewAction.delete,
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

enum DocDetailsViewAction { delete }
