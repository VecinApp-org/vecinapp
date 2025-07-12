import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';

class RulebookListView extends StatelessWidget {
  final List<Rulebook> rulebooks;

  const RulebookListView({
    super.key,
    required this.rulebooks,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: rulebooks.length,
        itemBuilder: (context, index) {
          final rulebook = rulebooks.elementAt(index);
          return CustomCard(
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
          );
        });
  }
}
