import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';

class RulebookListView extends StatelessWidget {
  final Iterable<Rulebook> rulebooks;

  const RulebookListView({
    super.key,
    required this.rulebooks,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: rulebooks.length,
        itemBuilder: (context, index) {
          final rulebook = rulebooks.elementAt(index);
          return Column(
            children: [
              Card(
                color: Theme.of(context).colorScheme.surfaceContainer,
                margin:
                    const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, top: 5.0),
                  child: ListTile(
                    leading: const Icon(Icons.library_books_outlined),
                    onTap: () {
                      context.read<AppBloc>().add(
                            AppEventGoToRulebookDetailsView(
                              rulebook: rulebook,
                            ),
                          );
                    },
                    title: Text(
                      rulebook.title,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
