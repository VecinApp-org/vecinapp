import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/bloc/loading_messages_constants.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/extensions/formatting/format_date_time.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';
import 'package:vecinapp/utilities/widgets/edit_or_delete_popup.dart';
import 'package:vecinapp/views/events/edit_event_view.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class EventDetailsView extends HookWidget {
  const EventDetailsView({super.key, required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final isAdmin = useMemoized(() =>
        context.read<AppBloc>().state.cloudUser?.isNeighborhoodAdmin ?? false);
    return BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          final shouldPop = state.loadingText == loadingTextEventDeleteSuccess;
          if (shouldPop && !state.isLoading) {
            Navigator.of(context).pop();
          }
        },
        child: DocView(
          title: event.title,
          text: event.text,
          appBarActions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () =>
                  SharePlus.instance.share(ShareParams(text: event.shareEvent)),
            ),
            Visibility(
              visible: isAdmin,
              child: EditOrDeletePopupMenuIcon(
                editAction: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditEventView(event: event),
                  ));
                },
                deleteAction: () => context
                    .read<AppBloc>()
                    .add(AppEventDeleteEvent(eventId: event.id)),
              ),
            )
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                '📅  ${formatDateTime(event.dateStart, endTime: event.dateEnd)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '📍  ${event.placeName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ));
  }
}
