import 'package:flutter/material.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/services/crud/docs_service.dart';
import 'dart:developer' as devtools show log;

class NewDocView extends StatefulWidget {
  const NewDocView({super.key});

  @override
  State<NewDocView> createState() => _NewDocViewState();
}

class _NewDocViewState extends State<NewDocView> {
  //DatabaseDoc? _doc;
  late final DocsService _docsService;
  late final TextEditingController _textController;
  late final TextEditingController _titleController;

  Future<void> _createDocIfNotEmpty() async {
    final text = _textController.text;
    final title = _titleController.text;
    final currentUser = AuthService.firebase().currentUser!;
    final uid = currentUser.uid;

    if (title.isNotEmpty && text.isNotEmpty) {
      try {
        final owner = await _docsService.getUser(authId: uid);
        await _docsService.createDoc(
          owner: owner,
          title: title,
          text: text,
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  void dispose() {
    _createDocIfNotEmpty();
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _docsService = DocsService();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('NewDocView');
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Doc'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Título...',
                ),
                controller: _titleController,
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Texto...',
                ),
                controller: _textController,
              ),
            ],
          ),
        ));
  }
}
