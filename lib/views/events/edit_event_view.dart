import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class EditEventView extends HookWidget {
  const EditEventView({super.key, this.event});
  final Event? event;

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final titleController = useTextEditingController();

    if (event != null) {
      if (event!.text.isNotEmpty && event!.title.isNotEmpty) {
        textController.text = event!.text;
        titleController.text = event!.title;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Evento'),
        leading: BackButton(
            onPressed: () =>
                context.read<AppBloc>().add(const AppEventGoToEventsView())),
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
          TextField(),
          const SizedBox(height: 8.0),
          TextField(
            controller: textController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 32.0),
          FilledButton(
            onPressed: () async {
              context.read<AppBloc>().add(AppEventCreateOrUpdateEvent(
                    title: titleController.text,
                    text: textController.text,
                    dateStart: DateTime.now(),
                    dateEnd: DateTime.now(),
                    placeName: 'Default',
                    location: null,
                  ));
            },
            child: const Text('Guardar'),
          )
        ],
      ),
    );
  }
}
