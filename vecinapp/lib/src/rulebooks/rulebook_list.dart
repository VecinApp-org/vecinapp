import 'package:flutter/material.dart';
import 'rulebook.dart';
import 'rulebook_details_view.dart';

/// Displays a list of SampleItems.
class RulebookList extends StatelessWidget {
  static const title = Text('Reglamentos');
  static const icon = Icon(Icons.book_outlined);
  static const selectedIcon = Icon(Icons.book);

  const RulebookList({
    super.key,
    this.rulebooks = const [
      Rulebook(1, 'Reglamento 1', 'Descripción 1'),
      Rulebook(2, 'Reglamento 2', 'Descripción 2'),
      Rulebook(3, 'Reglamento 3', 'Descripción 3')
    ],
  });

  final List<Rulebook> rulebooks;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      restorationId: 'rulebookList',
      itemCount: rulebooks.length,
      itemBuilder: (context, index) {
        final rulebook = rulebooks[index];
        return Column(
          children: [
            ListTile(
                title: Text(rulebook.title),
                leading: const Icon(Icons.book_outlined),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RulebookDetailsView(rulebook: rulebook),
                    ),
                  );
                }),
            const Divider(),
          ],
        );
      },
    );
  }
}
