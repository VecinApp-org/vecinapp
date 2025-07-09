import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';
import 'package:vecinapp/utilities/widgets/edit_or_delete_popup.dart';
import 'package:vecinapp/views/user_list_view.dart';

class EventDetailsView extends HookWidget {
  const EventDetailsView(
      {super.key, required this.event, required this.cloudUser});
  final Event event;
  final CloudUser cloudUser;

  @override
  Widget build(BuildContext context) {
    return DocView(
      title: event.title,
      text: event.text,
      appBarBackAction: () =>
          context.read<AppBloc>().add(const AppEventGoToEventsView()),
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => Share.share(event.shareEvent),
        ),
        Visibility(
          visible: cloudUser.isNeighborhoodAdmin,
          child: EditOrDeletePopupMenuIcon(
            editAction: () =>
                context.read<AppBloc>().add(AppEventGoToEditEventView(
                      event: event,
                    )),
            deleteAction: () =>
                context.read<AppBloc>().add(AppEventDeleteEvent()),
          ),
        )
      ],
      children: [
        const SizedBox(height: 8),
        Text(
          '📅  ${DateFormat.EEEE().add_d().add_MMMM().add_jm().format(event.dateStart)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '📍  ${event.placeName}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        UserListView(users: [])
      ],
    );
  }
}
