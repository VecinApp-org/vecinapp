import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/views/rulebooks/rulebook_list_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RulebooksView extends HookWidget {
  const RulebooksView({super.key, required this.cloudUser});
  final CloudUser cloudUser;
  @override
  Widget build(BuildContext context) {
    final stream = useMemoized(() => context.watch<AppBloc>().rulebooks);
    final rulebooks = useStream(stream);
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventGoToNeighborhoodView())),
          //title: const Text('Reglamentos'),
        ),
        floatingActionButton: Visibility(
          visible: cloudUser.adminLevel >= 3,
          child: FloatingActionButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventGoToEditRulebookView()),
              child: const Icon(Icons.add)),
        ),
        body: RulebookListView(rulebooks: rulebooks.data ?? []));
  }
}
