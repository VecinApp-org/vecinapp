import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/views/rulebooks/edit_rulebook_view.dart';
import 'package:vecinapp/views/rulebooks/rulebook_list_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RulebooksView extends HookWidget {
  const RulebooksView({super.key, required this.cloudUser});
  final CloudUser cloudUser;
  @override
  Widget build(BuildContext context) {
    final stream = useMemoized(() => context.watch<AppBloc>().rulebooks);
    final rulebooks = useStream(stream);

    final list = rulebooks.data?.toList() ?? [];
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos'),
        actions: [
          Visibility(
            visible: cloudUser.isNeighborhoodAdmin,
            child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const EditRulebookView(),
                  ));
                }),
          )
        ],
      ),
      body: (rulebooks.data == null)
          ? Container()
          : (rulebooks.data!.isEmpty)
              ? const Center(child: Text('No hay recursos'))
              : RulebookListView(rulebooks: list),
    );
  }
}
