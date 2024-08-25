import 'package:flutter/material.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/services/crud/docs_service.dart';

class DocsView extends StatefulWidget {
  const DocsView({super.key});

  @override
  State<DocsView> createState() => _DocsViewState();
}

class _DocsViewState extends State<DocsView> {
  late final DocsService _docsService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    super.initState();
    _docsService = DocsService();
  }

  @override
  void dispose() {
    _docsService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _docsService.getOrCreateUser(email: userEmail),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return StreamBuilder(
                stream: _docsService.allDocs,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Center(
                        child: Text('waiting...'),
                      );
                    case ConnectionState.active:
                      return const Text('active');
                    default:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                });
          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }
}
