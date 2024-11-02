import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/rulebook.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EditRulebookView extends HookWidget {
  const EditRulebookView({super.key, this.rulebook});
  final Rulebook? rulebook;
  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final titleController = useTextEditingController();
    (rulebook != null)
        ? textController.text = rulebook!.text
        : titleController.text = rulebook!.title;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Reglamento'),
        leading: BackButton(
            onPressed: () =>
                context.read<AppBloc>().add(const AppEventGoToRulebooksView())),
      ),
      body: ListView(
        padding: const EdgeInsets.all(33),
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: textController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(labelText: 'Contenido'),
          ),
          const SizedBox(height: 32.0),
          FilledButton(
            onPressed: () async {
              context.read<AppBloc>().add(AppEventCreateOrUpdateRulebook(
                    title: titleController.text,
                    text: textController.text,
                  ));
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }
}
