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
  DatabaseDoc? _doc;
  late final DocsService _docsService;
  late final TextEditingController _textController;

  Future<DatabaseDoc> createDoc() async {
    final existingNote = _doc;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final uid = currentUser.uid;
    final owner = await _docsService.getUser(authId: uid);
    return await _docsService.createDoc(owner: owner);
  }

  void _deleteDocIfTextIsEmpty() {
    devtools.log('deleteDocIfTextIsEmpty');
    final doc = _doc;
    if (_textController.text.isEmpty && doc != null) {
      _docsService.deleteDoc(id: doc.id);
    }
  }

  void _saveDocIfTextNotEmpty() async {
    devtools.log('saveDocIfTextNotEmpty');
    final doc = _doc;
    final text = _textController.text;
    if (text.isNotEmpty && doc != null) {
      await _docsService.updateDoc(doc: doc, text: text);
    }
  }

  @override
  void initState() {
    _docsService = DocsService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final doc = _doc;
    if (doc == null) {
      return;
    }
    final text = _textController.text;
    await _docsService.updateDoc(
      doc: doc,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    _deleteDocIfTextIsEmpty();
    _saveDocIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Doc'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
              future: createDoc(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    _doc = snapshot.data;
                    _setupTextControllerListener();
                    return TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Start typing here...',
                      ),
                      controller: _textController,
                    );
                  default:
                    return const CircularProgressIndicator();
                }
              }),
        ));
  }
}
