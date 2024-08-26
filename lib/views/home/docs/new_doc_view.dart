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

  Future<DatabaseDoc> _createDoc() async {
    final existingNote = _doc;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;

    final uid = currentUser.uid;
    devtools.log('uid: $uid');
    try {
      final owner = await _docsService.getUser(authId: uid);
      devtools.log('owner: $owner');
      return await _docsService.createDoc(owner: owner);
    } catch (e) {
      devtools.log('Error: $e');
      rethrow;
    }
  }

  void _deleteDocIfTextIsEmpty() {
    final doc = _doc;
    if (_textController.text.isEmpty && doc != null) {
      devtools.log('deleteDocIfTextIsEmpty');
      _docsService.deleteDoc(id: doc.id);
    }
  }

  void _saveDocIfTextNotEmpty() async {
    final doc = _doc;
    final text = _textController.text;
    if (text.isNotEmpty && doc != null) {
      devtools.log('saveDocIfTextNotEmpty');
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
    devtools.log('_setupTextControllerListener');
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    _saveDocIfTextNotEmpty();
    _deleteDocIfTextIsEmpty();
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
              future: _createDoc(),
              builder: (context, snapshot) {
                devtools.log('Creating doc: ${snapshot.connectionState}');
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    devtools.log('Doc created: ${snapshot.data}');
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
