import 'package:flutter/material.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:vecinapp/views/rulebooks/rulebook_details_view.dart';
import 'dart:developer' as devtools show log;

class RulebookListView extends StatelessWidget {
  final Iterable<Rulebook> rulebooks;

  const RulebookListView({
    super.key,
    required this.rulebooks,
  });

  @override
  Widget build(BuildContext context) {
    devtools.log('RulebookListView');
    return ListView.builder(
        itemCount: rulebooks.length,
        itemBuilder: (context, index) {
          final rulebook = rulebooks.elementAt(index);
          return Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RulebookDetailsView(rulebook: rulebook),
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
