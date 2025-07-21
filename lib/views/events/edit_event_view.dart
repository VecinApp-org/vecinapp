import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/bloc/loading_messages_constants.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class EditEventView extends HookWidget {
  const EditEventView({super.key, this.event});
  final Event? event;

  @override
  Widget build(BuildContext context) {
    devtools.log('EditEventView build');
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
          DateFormat.MMMEd().format(selectedStartDate.value!);
      timeStartController.text =
          DateFormat.jm().format(selectedStartDate.value!);
      dateEndController.text =
          DateFormat.MMMEd().format(selectedEndDate.value!);
      timeEndController.text = DateFormat.jm().format(selectedEndDate.value!);
    }

    return BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          final loadingText = state.loadingText;
          final isLoading = state.isLoading;
          if (loadingText == loadingTextEventEditSuccess && !isLoading) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: DocView(
          appBarTitle: event == null ? 'Nuevo Evento' : 'Editar Evento',
          title: null,
          text: null,
          appBarActions: null,
          child: Column(
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
                                      decoration: const InputDecoration(
                                          labelText: 'Fecha'),
                                      readOnly: true,
                                      onTap: () async {
                                        // show the date picker
                                        final newStartDate =
                                            await showDatePicker(
                                          context: context,
                                          firstDate: DateTime.now().subtract(
                                              const Duration(days: 60)),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                          currentDate: DateTime.now(),
                                          initialDate:
                                              selectedStartDate.value ??
                                                  DateTime.now(),
                                        );
                                        if (newStartDate != null &&
                                            newStartDate !=
                                                selectedStartDate.value) {
                                          final oldDateStart =
                                              selectedStartDate.value!;
                                          final oldDateEnd =
                                              selectedEndDate.value!;
                                          final timeDifference = oldDateEnd
                                              .difference(oldDateStart);
                                          devtools
                                              .log(timeDifference.toString());
                                          // update the start and end dates
                                          selectedStartDate.value =
                                              newStartDate.add(Duration(
                                                  hours: oldDateStart.hour,
                                                  minutes:
                                                      oldDateStart.minute));
                                          selectedEndDate.value =
                                              selectedStartDate.value!
                                                  .add(timeDifference);
                                          // update the text controllers
                                          dateStartController.text =
                                              DateFormat.MMMEd().format(
                                                  selectedStartDate.value!);
                                          timeStartController.text =
                                              DateFormat.jm().format(
                                                  selectedStartDate.value!);
                                          dateEndController.text =
                                              DateFormat.MMMEd().format(
                                                  selectedEndDate.value!);
                                          timeEndController.text =
                                              DateFormat.jm().format(
                                                  selectedEndDate.value!);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: TextField(
                                      controller: timeStartController,
                                      decoration: const InputDecoration(
                                          labelText: 'Hora'),
                                      readOnly: true,
                                      onTap: () async {
                                        final newStartTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                              selectedStartDate.value ??
                                                  DateTime.now()),
                                        );
                                        if (newStartTime != null) {
                                          final oldDateStart =
                                              selectedStartDate.value!;
                                          final oldDateEnd =
                                              selectedEndDate.value!;
                                          final timeDifference = oldDateEnd
                                              .difference(oldDateStart);
                                          // update the start and end dates
                                          selectedStartDate.value = DateTime(
                                            oldDateStart.year,
                                            oldDateStart.month,
                                            oldDateStart.day,
                                            newStartTime.hour,
                                            newStartTime.minute,
                                          );
                                          selectedEndDate.value =
                                              selectedStartDate.value!
                                                  .add(timeDifference);
                                          // update the text controllers
                                          dateStartController.text =
                                              DateFormat.MMMEd().format(
                                                  selectedStartDate.value!);
                                          timeStartController.text =
                                              DateFormat.jm().format(
                                                  selectedStartDate.value!);
                                          dateEndController.text =
                                              DateFormat.MMMEd().format(
                                                  selectedEndDate.value!);
                                          timeEndController.text =
                                              DateFormat.jm().format(
                                                  selectedEndDate.value!);
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
                                          firstDate: selectedStartDate.value ??
                                              DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                          currentDate: DateTime.now(),
                                          initialDate: selectedEndDate.value ??
                                              DateTime.now(),
                                        );
                                        if (newEndDate != null &&
                                            newEndDate !=
                                                selectedEndDate.value) {
                                          final oldDateEnd =
                                              selectedEndDate.value!;
                                          selectedEndDate.value =
                                              newEndDate.add(Duration(
                                            hours: oldDateEnd.hour,
                                            minutes: oldDateEnd.minute,
                                          ));
                                          dateEndController.text =
                                              DateFormat.MMMEd().format(
                                                  selectedEndDate.value!);
                                          timeEndController.text =
                                              DateFormat.jm().format(
                                                  selectedEndDate.value!);
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
                                        final oldDateEnd =
                                            selectedEndDate.value!;
                                        final newEndTime = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                              oldDateEnd),
                                        );
                                        if (newEndTime != null) {
                                          selectedEndDate.value = DateTime(
                                            oldDateEnd.year,
                                            oldDateEnd.month,
                                            oldDateEnd.day,
                                            newEndTime.hour,
                                            newEndTime.minute,
                                          );
                                          dateEndController.text =
                                              DateFormat.MMMEd().format(
                                                  selectedEndDate.value!);
                                          timeEndController.text =
                                              DateFormat.jm().format(
                                                  selectedEndDate.value!);
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
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8.0),
                        TextButton.icon(
                          iconAlignment: IconAlignment.start,
                          label: const Text('Agregar Fecha'),
                          icon: const Icon(Icons.calendar_month),
                          onPressed: () async {
                            final newStartDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 60)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              currentDate: DateTime.now(),
                              initialDate: DateTime.now(),
                            );
                            if (newStartDate != null) {
                              selectedStartDate.value = newStartDate;
                              dateStartController.text = DateFormat.MMMEd()
                                  .format(selectedStartDate.value!);
                              timeStartController.text = DateFormat.jm()
                                  .format(selectedStartDate.value!);
                              selectedEndDate.value =
                                  newStartDate.add(Duration(hours: 1));
                              dateEndController.text = DateFormat.MMMEd()
                                  .format(selectedEndDate.value!);
                              timeEndController.text = DateFormat.jm()
                                  .format(selectedEndDate.value!);
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
                        eventId: event?.id,
                        title: titleController.text,
                        text: textController.text,
                        dateStart: selectedStartDate.value,
                        dateEnd: selectedEndDate.value,
                        placeName: placeController.text,
                        location: null,
                      ));
                },
                child: const Text('Guardar'),
              )
            ],
          ),
        ));
  }
}
