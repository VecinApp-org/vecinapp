import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';

class EditRulebookView extends StatefulWidget {
  const EditRulebookView({super.key, this.rulebook});

  final Rulebook? rulebook;

  @override
  State<EditRulebookView> createState() => _EditRulebookViewState();
}

class _EditRulebookViewState extends State<EditRulebookView> {
  late final TextEditingController _textController;
  late final TextEditingController _titleController;

  @override
  void initState() {
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
                final text = _textController.text;
                final title = _titleController.text;
                context.read<AppBloc>().add(AppEventCreateOrUpdateRulebook(
                      title: title,
                      text: text,
                    ));
              },
              child: const Text('Guardar'),
            )
          ],
        ));
  }
}
