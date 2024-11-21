import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:vecinapp/utilities/dialogs/show_confirmation_dialog.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RulebookDetailsView extends HookWidget {
  const RulebookDetailsView({super.key, required this.rulebook});
  final Rulebook rulebook;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventGoToRulebooksView())),
          actions: [
            IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => Share.share(rulebook.shareRulebook)),
            PopupMenuButton<EditOrDelete>(onSelected: (value) async {
              switch (value) {
                case EditOrDelete.edit:
                  context.read<AppBloc>().add(AppEventGoToEditRulebookView(
                        rulebook: rulebook,
                      ));
                case EditOrDelete.delete:
                  final shouldDelete = await showConfirmationDialog(
                      context: context, text: '¿Eliminar el reglamento?');
                  if (shouldDelete && context.mounted) {
                    context.read<AppBloc>().add(const AppEventDeleteRulebook());
                  }
              }
            }, itemBuilder: (context) {
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
            })
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(32.0),
          children: [
            Text(
              rulebook.title,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            Text(rulebook.text)
          ],
        ));
  }
}

enum EditOrDelete {
  edit,
  delete,
}
