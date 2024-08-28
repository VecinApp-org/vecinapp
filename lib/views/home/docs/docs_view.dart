import 'package:flutter/material.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/services/cloud/cloud_doc.dart';
import 'package:vecinapp/services/cloud/firebase_cloud_storage.dart';
import 'package:vecinapp/constants/routes.dart';
import 'dart:developer' as devtools show log;

import 'package:vecinapp/views/home/docs/docs_list_view.dart';

class DocsView extends StatefulWidget {
  const DocsView({super.key});

  @override
  State<DocsView> createState() => _DocsViewState();
}

class _DocsViewState extends State<DocsView> {
  late final FirebaseCloudStorage _docsService;
  String get userId => AuthService.firebase().currentUser!.uid;

  @override
  void initState() {
    _docsService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('DocsView');
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(newDocRouteName);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _docsService.allDocs(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudDoc>;
                return DocsListView(
                  docs: allNotes,
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
