import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/rulebook.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';

class EditRulebookView extends HookWidget {
  const EditRulebookView({super.key, this.rulebook});
  final Rulebook? rulebook;

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final titleController = useTextEditingController();
    //populate the fields with the rulebook data
    if (rulebook != null) {
      if (rulebook!.text.isNotEmpty && rulebook!.title.isNotEmpty) {
        textController.text = rulebook!.text;
        titleController.text = rulebook!.title;
      }
    }
    return DocView(
      appBarTitle: rulebook == null ? 'Nuevo Reglamento' : 'Editar Reglamento',
      title: null,
      text: null,
      appBarBackAction: () =>
          context.read<AppBloc>().add(const AppEventGoToRulebooksView()),
      appBarActions: null,
      children: [
        TextField(
          controller: titleController,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          minLines: 1,
          decoration: const InputDecoration(labelText: 'Título'),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          maxLines: 10,
          minLines: 1,
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
    );
  }
}
