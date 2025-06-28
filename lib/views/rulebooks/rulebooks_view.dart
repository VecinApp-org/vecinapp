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

    if (rulebooks.data == null) {
      return Container();
    }

    if (rulebooks.data!.isEmpty) {
      return const Center(child: Text('No hay recursos'));
    }

    final list = rulebooks.data!.toList();
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos'),
        actions: [
          Visibility(
            visible: cloudUser.isNeighborhoodAdmin,
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventGoToEditRulebookView()),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(child: RulebookListView(rulebooks: list)),
    );
  }
}
