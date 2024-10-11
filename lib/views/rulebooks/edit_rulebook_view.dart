import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_service.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/cloud_storage_exceptions.dart';
import 'package:vecinapp/services/cloud/firebase_cloud_storage.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:vecinapp/utilities/dialogs/show_error_dialog.dart';
import 'dart:developer' as devtools show log;

class EditRulebookView extends StatefulWidget {
  const EditRulebookView({super.key, this.rulebook});

  final Rulebook? rulebook;

  @override
  State<EditRulebookView> createState() => _EditRulebookViewState();
}

class _EditRulebookViewState extends State<EditRulebookView> {
  late final FirebaseCloudProvider _dbService;
  late final TextEditingController _textController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    _dbService = FirebaseCloudProvider();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    _setupEditRulebookIfProvided();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _setupEditRulebookIfProvided() {
    if (widget.rulebook != null) {
      _textController.text = widget.rulebook!.text;
      _titleController.text = widget.rulebook!.title;
    }
  }

  Future<void> _createOrUpdateRulebook() async {
    final text = _textController.text;
    final title = _titleController.text;

    try {
      if (widget.rulebook == null) {
        final currentUser = AuthService.firebase().currentUser!;
        final uid = currentUser.uid!;
        await _dbService.createNewRulebook(
          ownerUserId: uid,
          title: title,
          text: text,
        );
      } else {
        await _dbService.updateRulebook(
          rulebookId: widget.rulebook!.id,
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
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              context.read<AppBloc>().add(const AppEventGoToRulebooksView());
            },
          ),
          title: const Text('Editar Reglamento'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextField(
              autofocus: true,
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
                  await _createOrUpdateRulebook();
                  if (context.mounted) {
                    context
                        .read<AppBloc>()
                        .add(const AppEventGoToRulebooksView());
                  }
                } on CloudStorageException catch (e) {
                  devtools.log('CloudStorageException on save rulebook: $e');
                  if (context.mounted) {
                    showErrorDialog(
                      context: context,
                      text: 'Error al guardar el reglamento',
                    );
                  }
                } catch (e) {
                  devtools.log(
                      'Unhandled exception saving rulebook type ${e.runtimeType} Error: $e');
                  if (context.mounted) {
                    showErrorDialog(
                      context: context,
                      text: 'Error al guardar el reglamento',
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
