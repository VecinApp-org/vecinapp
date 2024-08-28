import 'package:flutter/material.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/services/cloud/cloud_doc.dart';
import 'package:vecinapp/services/cloud/cloud_storage_exceptions.dart';
import 'package:vecinapp/services/cloud/firebase_cloud_storage.dart';
import 'dart:developer' as devtools show log;

import 'package:vecinapp/utilities/show_error_dialog.dart';

class EditDocView extends StatefulWidget {
  const EditDocView({super.key, this.doc});

  final CloudDoc? doc;

  @override
  State<EditDocView> createState() => _EditDocViewState();
}

class _EditDocViewState extends State<EditDocView> {
  //DatabaseDoc? _doc;
  late final FirebaseCloudStorage _docsService;
  late final TextEditingController _textController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    _docsService = FirebaseCloudStorage();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    _setupEditDocIfProvided();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _setupEditDocIfProvided() {
    if (widget.doc != null) {
      _textController.text = widget.doc!.text;
      _titleController.text = widget.doc!.title;
    }
  }

  Future<void> _createOrUpdateDoc() async {
    final text = _textController.text;
    final title = _titleController.text;

    try {
      if (widget.doc == null) {
        final currentUser = AuthService.firebase().currentUser!;
        final uid = currentUser.uid;
        await _docsService.createNewDoc(
          ownerUserId: uid,
          title: title,
          text: text,
        );
      } else {
        await _docsService.updateDoc(
          documentId: widget.doc!.documentId,
          title: title,
          text: text,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    devtools.log('NewDocView');
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nuevo Documento'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'Título',
                //hintText: 'Título...',
              ),
              controller: _titleController,
            ),
            const SizedBox(height: 8.0),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Contenido',
              ),
              controller: _textController,
            ),
            const SizedBox(height: 32.0),
            FilledButton(
              onPressed: () async {
                try {
                  await _createOrUpdateDoc();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } on CloudStorageException catch (e) {
                  devtools.log('CloudStorageException on save doc: $e');
                  if (context.mounted) {
                    showErrorDialog(
                      context,
                      'Error al guardar el documento',
                    );
                  }
                } catch (e) {
                  devtools.log(
                      'Unhandled exception saving doc type ${e.runtimeType} Error: $e');
                  if (context.mounted) {
                    showErrorDialog(
                      context,
                      'Error al guardar el documento',
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            )
          ],
        ));
  }
}
