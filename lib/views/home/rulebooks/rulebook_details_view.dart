import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:vecinapp/services/cloud/firebase_cloud_storage.dart';
import 'package:vecinapp/utilities/show_confirmation_dialog.dart';
import 'package:vecinapp/views/home/rulebooks/edit_rulebook_view.dart';

class RulebookDetailsView extends StatefulWidget {
  const RulebookDetailsView({super.key, required this.rulebook});
  final Rulebook rulebook;

  @override
  State<RulebookDetailsView> createState() => _RulebookDetailsViewState();
}

class _RulebookDetailsViewState extends State<RulebookDetailsView> {
  final _dbService = FirebaseCloudStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(widget.rulebook.shareRulebook);
            },
          ),
          PopupMenuButton<EditOrDelete>(
            onSelected: (value) async {
              switch (value) {
                case EditOrDelete.edit:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditRulebookView(rulebook: widget.rulebook),
                    ),
                  );
                case EditOrDelete.delete:
                  final shouldDelete = await showConfirmationDialog(
                      context: context, text: '¿Eliminar el reglamento?');
                  if (shouldDelete == true) {
                    await _dbService.deleteRulebook(
                        rulebookId: widget.rulebook.id);
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
            widget.rulebook.title,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 32),
          Text(widget.rulebook.text),
        ],
      ),
    );
  }
}

enum EditOrDelete {
  edit,
  delete,
}
