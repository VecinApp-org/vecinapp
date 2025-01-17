import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';

class EditEventView extends HookWidget {
  const EditEventView({super.key, this.event});
  final Event? event;

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    final textController = useTextEditingController();
    final titleController = useTextEditingController();
    final placeController = useTextEditingController();
    final dateStartController = useTextEditingController();
    final timeStartController = useTextEditingController();

    if (event != null) {
      textController.text = event!.text;
      titleController.text = event!.title;
      placeController.text = event!.placeName;
      selectedDate = event!.dateStart;
    }

    dateStartController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    timeStartController.text = DateFormat('hh:mm a').format(selectedDate);

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
        dateStartController.text = selectedDate.toLocal().toString();
      }
    }

    return DocView(
      appBarTitle: event == null ? 'Nuevo Evento' : 'Editar Evento',
      title: null,
      text: null,
      appBarBackAction: () =>
          context.read<AppBloc>().add(const AppEventGoToEventsView()),
      appBarActions: null,
      more: [
        TextField(
          controller: titleController,
          readOnly: true,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          minLines: 1,
          decoration: const InputDecoration(labelText: 'Título'),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: dateStartController,
                decoration: const InputDecoration(labelText: 'Fecha'),
                readOnly: true,
                onTap: () => selectDate(context),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: TextField(
                controller: timeStartController,
                decoration: const InputDecoration(labelText: 'Hora'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: placeController,
          decoration: const InputDecoration(labelText: 'Lugar'),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          maxLines: 10,
          minLines: 1,
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
                  placeName: placeController.text,
                  location: null,
                ));
          },
          child: const Text('Guardar'),
        )
      ],
    );
  }
}
