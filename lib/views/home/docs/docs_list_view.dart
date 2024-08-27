import 'package:flutter/material.dart';
import 'package:vecinapp/services/crud/docs_service.dart';
import 'package:vecinapp/views/home/docs/docs_details_view.dart';
import 'dart:developer' as devtools show log;

class DocsListView extends StatelessWidget {
  final List<DatabaseDoc> docs;

  const DocsListView({
    super.key,
    required this.docs,
  });

  @override
  Widget build(BuildContext context) {
    devtools.log('DocsListView');
    return ListView.builder(
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          return Column(
            children: [
              ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocDetailsView(doc: doc),
                  ),
                ),
                title: Text(
                  doc.title,
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
