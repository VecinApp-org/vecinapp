import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';
import 'package:vecinapp/utilities/widgets/edit_or_delete_popup.dart';

class RulebookDetailsView extends HookWidget {
  const RulebookDetailsView(
      {super.key, required this.rulebook, required this.cloudUser});
  final Rulebook rulebook;
  final CloudUser cloudUser;

  @override
  Widget build(BuildContext context) {
    return DocView(
      title: rulebook.title,
      text: rulebook.text,
      more: null,
      appBarBackAction: () =>
          context.read<AppBloc>().add(const AppEventGoToRulebooksView()),
      appBarActions: [
        IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(rulebook.shareRulebook)),
        Visibility(
          visible: cloudUser.isNeighborhoodAdmin,
          child: EditOrDeletePopupMenuIcon(
            editAction: () => context
                .read<AppBloc>()
                .add(AppEventGoToEditRulebookView(rulebook: rulebook)),
            deleteAction: () =>
                context.read<AppBloc>().add(const AppEventDeleteRulebook()),
          ),
        ),
      ],
    );
  }
}
