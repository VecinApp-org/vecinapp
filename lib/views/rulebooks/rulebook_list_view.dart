import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';
import 'package:vecinapp/views/rulebooks/rulebook_details_view.dart';

class RulebookListView extends StatelessWidget {
  final List<Rulebook> rulebooks;

  const RulebookListView({
    super.key,
    required this.rulebooks,
  });

  @override
  Widget build(BuildContext context) {
    if (rulebooks.isEmpty) {
      return const SizedBox.shrink();
    }
    rulebooks.sort((a, b) => a.title.compareTo(b.title));
    return ListView.builder(
        shrinkWrap: true,
        itemCount: rulebooks.length,
        itemBuilder: (context, index) {
          final rulebook = rulebooks.elementAt(index);
          return CustomCard(
            child: ListTile(
              leading: const Icon(Icons.library_books_outlined),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RulebookDetailsView(rulebook: rulebook),
                ));
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
