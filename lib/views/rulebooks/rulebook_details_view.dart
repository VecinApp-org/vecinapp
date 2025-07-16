import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/bloc/loading_messages_constants.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';
import 'package:vecinapp/utilities/widgets/edit_or_delete_popup.dart';
import 'package:vecinapp/views/rulebooks/edit_rulebook_view.dart';

class RulebookDetailsView extends HookWidget {
  const RulebookDetailsView({super.key, required this.rulebook});
  final Rulebook rulebook;

  @override
  Widget build(BuildContext context) {
    final cloudUser = context.read<AppBloc>().state.cloudUser;
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        final shouldPop =
            state.loadingText == loadingTextRulebookDeletionSuccess;
        final isLoading = state.isLoading;
        if (shouldPop && !isLoading) {
          Navigator.of(context).pop();
        }
      },
      child: DocView(
        title: rulebook.title,
        text: rulebook.text,
        appBarActions: [
          IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => SharePlus.instance
                  .share(ShareParams(text: rulebook.shareRulebook))),
          Visibility(
            visible: cloudUser!.isNeighborhoodAdmin,
            child: EditOrDeletePopupMenuIcon(
              editAction: () async {
                final didUpdate =
                    await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditRulebookView(rulebook: rulebook),
                ));
                if (didUpdate && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              deleteAction: () => context
                  .read<AppBloc>()
                  .add(AppEventDeleteRulebook(rulebookId: rulebook.id)),
            ),
          ),
        ],
      ),
    );
  }
}
