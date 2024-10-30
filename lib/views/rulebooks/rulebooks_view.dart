import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';

import 'package:vecinapp/views/rulebooks/rulebook_list_view.dart';

class RulebooksView extends StatefulWidget {
  const RulebooksView({super.key});

  @override
  State<RulebooksView> createState() => _RulebooksViewState();
}

class _RulebooksViewState extends State<RulebooksView> {
  late final Stream<Iterable<Rulebook>> rulebooks;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    rulebooks = context.watch<AppBloc>().rulebooks;
  }

  @override
  Widget build(BuildContext context) {
    final rulebooks = context.watch<AppBloc>().rulebooks;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(
                  const AppEventGoToNeighborhoodView(),
                );
          },
        ),
        title: const Text('Reglamentos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<AppBloc>().add(
                const AppEventGoToEditRulebookView(),
              );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: rulebooks,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<Rulebook>;
                if (allNotes.isEmpty) {
                  return const Center(
                    child: Text('No hay reglamentos'),
                  );
                }
                return RulebookListView(
                  rulebooks: allNotes,
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
