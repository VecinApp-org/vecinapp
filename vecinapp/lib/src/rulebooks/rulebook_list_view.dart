import 'package:flutter/material.dart';
import 'rulebook.dart';
import 'rulebook_details_view.dart';
import '../home/drawer.dart';

/// Displays a list of SampleItems.
class RulebookListView extends StatelessWidget {
  const RulebookListView({
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reglamentos'),
      ),
      drawer: const HomeDrawer(),
      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'rulebookListView',
        itemCount: rulebooks.length,
        itemBuilder: (context, index) {
          final rulebook = rulebooks[index];
          return Column(
            children: [
              ListTile(
                  title: Text(rulebook.title),
                  leading: const Icon(Icons.book),
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
      ),
    );
  }
}
