import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:vecinapp/utilities/dialogs/show_confirmation_dialog.dart';

class RulebookDetailsView extends StatefulWidget {
  const RulebookDetailsView({super.key, required this.rulebook});
  final Rulebook rulebook;

  @override
  State<RulebookDetailsView> createState() => _RulebookDetailsViewState();
}

class _RulebookDetailsViewState extends State<RulebookDetailsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(
                  const AppEventGoToRulebooksView(),
                );
          },
        ),
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
                  context.read<AppBloc>().add(
                        AppEventGoToEditRulebookView(
                          rulebook: widget.rulebook,
                        ),
                      );
                case EditOrDelete.delete:
                  final shouldDelete = await showConfirmationDialog(
                      context: context, text: '¿Eliminar el reglamento?');
                  if (shouldDelete == true) {
                    if (context.mounted) {
                      context.read<AppBloc>().add(
                            AppEventDeleteRulebook(
                              rulebookId: widget.rulebook.id,
                            ),
                          );
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
