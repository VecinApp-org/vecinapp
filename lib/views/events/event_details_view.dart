import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:vecinapp/utilities/dialogs/show_confirmation_dialog.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EventDetailsView extends HookWidget {
  const EventDetailsView(
      {super.key, required this.event, required this.cloudUser});
  final Event event;
  final CloudUser cloudUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
              onPressed: () =>
                  context.read<AppBloc>().add(const AppEventGoToEventsView())),
          actions: [
            IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => Share.share(event.shareEvent)),
            Visibility(
              visible: cloudUser.isNeighborhoodAdmin,
              child: PopupMenuButton<EditOrDelete>(onSelected: (value) async {
                switch (value) {
                  case EditOrDelete.edit:
                    context.read<AppBloc>().add(AppEventGoToEditEventView(
                          event: event,
                        ));
                  case EditOrDelete.delete:
                    final shouldDelete = await showConfirmationDialog(
                        context: context, text: '¿Eliminar el evento?');
                    if (shouldDelete && context.mounted) {
                      context.read<AppBloc>().add(const AppEventDeleteEvent());
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
              }),
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(32.0),
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            Text(event.text)
          ],
        ));
  }
}

enum EditOrDelete {
  edit,
  delete,
}
