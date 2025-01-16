import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
      body: Card(
        color: Theme.of(context).colorScheme.surfaceContainer,
        margin: const EdgeInsets.all(8),
        child: ListView(
          padding: const EdgeInsets.only(left: 21.0, right: 21.0),
          children: [
            const SizedBox(height: 21),
            Text(
              event.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 13),
            Text(
              '📅  ${DateFormat.EEEE().add_d().add_MMMM().add_jm().format(event.dateStart)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              '📍  ${event.placeName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 13),
            Text(event.text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

enum EditOrDelete {
  edit,
  delete,
}
