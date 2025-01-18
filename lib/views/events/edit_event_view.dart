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
    DateTime? startDate;
    final selectedStartDate = useState<DateTime?>(startDate);
    DateTime? endDate;
    final selectedEndDate = useState<DateTime?>(endDate);
    final textController = useTextEditingController();
    final titleController = useTextEditingController();
    final placeController = useTextEditingController();
    final dateStartController = useTextEditingController();
    final timeStartController = useTextEditingController();
    final dateEndController = useTextEditingController();
    final timeEndController = useTextEditingController();
    // set values from event if it exists
    if (event != null) {
      textController.text = event!.text ?? '';
      titleController.text = event!.title;
      placeController.text = event!.placeName ?? '';
      selectedStartDate.value = event!.dateStart;
      selectedEndDate.value = event!.dateEnd;
      dateStartController.text =
          DateFormat('dd/MM/yyyy').format(selectedStartDate.value!);
      timeStartController.text =
          DateFormat('HH:mm').format(selectedStartDate.value!);
      dateEndController.text =
          DateFormat('dd/MM/yyyy').format(selectedEndDate.value!);
      timeEndController.text =
          DateFormat('HH:mm').format(selectedEndDate.value!);
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
        selectedStartDate.value != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: dateStartController,
                                decoration:
                                    const InputDecoration(labelText: 'Fecha'),
                                readOnly: true,
                                onTap: () async {
                                  final newStartDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 7)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                    currentDate: DateTime.now(),
                                    initialDate: selectedStartDate.value ??
                                        DateTime.now(),
                                  );
                                  if (newStartDate != null &&
                                      newStartDate != selectedStartDate.value) {
                                    selectedStartDate.value =
                                        newStartDate.add(Duration(
                                      hours:
                                          selectedStartDate.value?.hour ?? 10,
                                      minutes:
                                          selectedStartDate.value?.minute ?? 0,
                                    ));
                                    dateStartController.text =
                                        DateFormat.MMMEd()
                                            .format(selectedStartDate.value!);
                                    timeStartController.text = DateFormat.jm()
                                        .format(selectedStartDate.value!);
                                    selectedEndDate.value = selectedStartDate
                                        .value!
                                        .add(Duration(hours: 1));
                                    dateEndController.text = DateFormat.MMMEd()
                                        .format(selectedEndDate.value!);
                                    timeEndController.text = DateFormat.jm()
                                        .format(selectedEndDate.value!);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: TextField(
                                controller: timeStartController,
                                decoration:
                                    const InputDecoration(labelText: 'Hora'),
                                readOnly: true,
                                onTap: () async {
                                  final newStartDate = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                        selectedStartDate.value ??
                                            DateTime.now()),
                                  );
                                  if (newStartDate != null) {
                                    if (selectedStartDate.value == null) {
                                      selectedStartDate.value = DateTime(
                                        selectedStartDate.value?.year ??
                                            DateTime.now().year,
                                        selectedStartDate.value?.month ??
                                            DateTime.now().month,
                                        selectedStartDate.value?.day ??
                                            DateTime.now().day,
                                        newStartDate.hour,
                                        newStartDate.minute,
                                      );
                                      selectedEndDate.value = selectedStartDate
                                          .value!
                                          .add(Duration(hours: 1));
                                    } else {
                                      final timeDifference =
                                          selectedStartDate.value!.difference(
                                        selectedEndDate.value!,
                                      );
                                      selectedStartDate.value = DateTime(
                                        selectedStartDate.value!.year,
                                        selectedStartDate.value!.month,
                                        selectedStartDate.value!.day,
                                        newStartDate.hour,
                                        newStartDate.minute,
                                      );
                                      selectedEndDate.value = selectedStartDate
                                          .value!
                                          .add(timeDifference);
                                    }
                                    dateStartController.text =
                                        DateFormat.MMMEd()
                                            .format(selectedStartDate.value!);
                                    timeStartController.text = DateFormat.jm()
                                        .format(selectedStartDate.value!);
                                    dateEndController.text = DateFormat.MMMEd()
                                        .format(selectedEndDate.value!);
                                    timeEndController.text = DateFormat.jm()
                                        .format(selectedEndDate.value!);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: dateEndController,
                                decoration: const InputDecoration(
                                    labelText: 'Fecha Final'),
                                readOnly: true,
                                onTap: () async {
                                  final newEndDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 7)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)),
                                    currentDate: DateTime.now(),
                                    initialDate:
                                        selectedEndDate.value ?? DateTime.now(),
                                  );
                                  if (newEndDate != null &&
                                      newEndDate != selectedEndDate.value) {
                                    selectedEndDate.value =
                                        newEndDate.add(Duration(
                                      hours: selectedEndDate.value?.hour ?? 10,
                                      minutes:
                                          selectedEndDate.value?.minute ?? 0,
                                    ));
                                    dateEndController.text = DateFormat.MMMEd()
                                        .format(selectedEndDate.value!);
                                    timeEndController.text = DateFormat.jm()
                                        .format(selectedEndDate.value!);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: TextField(
                                controller: timeEndController,
                                decoration: const InputDecoration(
                                    labelText: 'Hora Final'),
                                readOnly: true,
                                onTap: () async {
                                  final newEndDate = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                        selectedEndDate.value ??
                                            DateTime.now()),
                                  );
                                  if (newEndDate != null) {
                                    selectedStartDate.value = DateTime(
                                      selectedStartDate.value?.year ??
                                          DateTime.now().year,
                                      selectedStartDate.value?.month ??
                                          DateTime.now().month,
                                      selectedStartDate.value?.day ??
                                          DateTime.now().day,
                                      newEndDate.hour,
                                      newEndDate.minute,
                                    );
                                    dateEndController.text = DateFormat.MMMEd()
                                        .format(selectedStartDate.value!);
                                    timeEndController.text = DateFormat.jm()
                                        .format(selectedStartDate.value!);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      selectedStartDate.value = null;
                      dateStartController.text = '';
                      timeStartController.text = '';
                      selectedEndDate.value = null;
                      dateEndController.text = '';
                      timeEndController.text = '';
                    },
                  ),
                  const SizedBox(width: 8.0),
                ],
              )
            : Row(
                children: [
                  TextButton.icon(
                    iconAlignment: IconAlignment.start,
                    label: const Text('Agregar Fecha'),
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () async {
                      final newStartDate = await showDatePicker(
                        context: context,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 7)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        currentDate: DateTime.now(),
                        initialDate: DateTime.now(),
                      );
                      if (newStartDate != null) {
                        selectedStartDate.value = newStartDate;
                        dateStartController.text =
                            DateFormat.MMMEd().format(selectedStartDate.value!);
                        timeStartController.text =
                            DateFormat.jm().format(selectedStartDate.value!);
                        selectedEndDate.value =
                            newStartDate.add(Duration(hours: 1));
                        dateEndController.text =
                            DateFormat.MMMEd().format(selectedEndDate.value!);
                        timeEndController.text =
                            DateFormat.jm().format(selectedEndDate.value!);
                      }
                    },
                  ),
                ],
              ),
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
