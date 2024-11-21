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
        itemCount: rulebooks.length,
        itemBuilder: (context, index) {
          final rulebook = rulebooks.elementAt(index);
          return Column(
            children: [
              ListTile(
                onTap: () {
                  context.read<AppBloc>().add(
                        AppEventGoToRulebookDetailsView(
                          rulebook: rulebook,
                        ),
                      );
                },
                title: Text(
                  rulebook.title,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
            ],
          );
        });
  }
}
