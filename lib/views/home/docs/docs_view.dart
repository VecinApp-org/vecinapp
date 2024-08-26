import 'package:flutter/material.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/services/crud/docs_service.dart';
import 'package:vecinapp/constants/routes.dart';
import 'dart:developer' as devtools show log;

class DocsView extends StatefulWidget {
  const DocsView({super.key});

  @override
  State<DocsView> createState() => _DocsViewState();
}

class _DocsViewState extends State<DocsView> {
  late final DocsService _docsService;
  String get userId => AuthService.firebase().currentUser!.uid;

  @override
  void initState() {
    _docsService = DocsService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(newDocRouteName);
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _docsService.getOrCreateUser(authId: userId),
        builder: (context, snapshot) {
          devtools.log('DocsUser: ${snapshot.connectionState}');
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _docsService.allDocs,
                builder: (context, snapshot) {
                  devtools.log('Get allDocs: ${snapshot.connectionState}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        devtools.log('snapshot.data: ${snapshot.data}');
                        final allNotes = snapshot.data as List<DatabaseDoc>;
                        return ListView.builder(
                            itemCount: allNotes.length,
                            itemBuilder: (context, index) {
                              final doc = allNotes[index];
                              return ListTile(
                                title: Text(
                                  doc.text,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            });
                      } else {
                        return const Center(
                          child: Center(
                            child: Text('No hay documentos'),
                          ),
                        );
                      }
                    default:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                },
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
