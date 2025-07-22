import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/services/bloc/loading_messages_constants.dart';
import 'package:vecinapp/utilities/entities/event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/custom_form_field.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class EditEventView extends HookWidget {
  const EditEventView({super.key, this.event});
  final Event? event;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    DateTime? startDate;
    final selectedStartDate = useState<DateTime?>(startDate);
    DateTime? endDate;
    final selectedEndDate = useState<DateTime?>(endDate);
    final textController = useTextEditingController();
    final titleController = useTextEditingController();
    final placeController = useTextEditingController();
    final dateStartController = useTextEditingController();
    final dateEndController = useTextEditingController();

    // set values from event if it exists
    if (event != null) {
      textController.text = event!.text ?? '';
      titleController.text = event!.title;
      placeController.text = event!.placeName ?? '';
      selectedStartDate.value = event!.dateStart;
      selectedEndDate.value = event!.dateEnd;
      dateStartController.text =
          DateFormat.MMMEd().format(selectedStartDate.value!);
      dateEndController.text =
          DateFormat.MMMEd().format(selectedEndDate.value!);
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
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CustomFormField(
                  hintText: 'Título',
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                  onSaved: (value) {
                    titleController.text = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Título requerido';
                    }
                    return null;
                  },
                ),
                CustomFormField(
                  controller: dateStartController,
                  hintText: 'Fecha',
                  readOnly: true,
                  suffixIcon: (selectedStartDate.value != null)
                      ? IconButton(
                          onPressed: () {
                            selectedStartDate.value = null;
                            dateStartController.text = '';
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.close))
                      : null,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Fecha requerida';
                    }
                    return null;
                  },
                  onSaved: (val) {},
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final previousDate = selectedStartDate.value ??
                        DateTime.now()
                            .copyWith(minute: 0)
                            .add(const Duration(hours: 1));
                    // show the date picker
                    final newStartDate = await showDatePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 60)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      currentDate: DateTime.now(),
                      initialDate: previousDate,
                    );
                    if (!context.mounted || newStartDate == null) {
                      return;
                    }
                    final newStartTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(previousDate),
                    );
                    if (!context.mounted || newStartTime == null) {
                      return;
                    }
                    //update start date
                    selectedStartDate.value = DateTime(
                        newStartDate.year,
                        newStartDate.month,
                        newStartDate.day,
                        newStartTime.hour,
                        newStartTime.minute);
                    //update text controllers
                    dateStartController.text =
                        '${DateFormat.MMMd().format(selectedStartDate.value!)} ${DateFormat.jm().format(selectedStartDate.value!)}';
                  },
                ),
                CustomFormField(
                  controller: dateEndController,
                  hintText: 'Fecha Final',
                  readOnly: true,
                  suffixIcon: (selectedEndDate.value != null)
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            selectedEndDate.value = null;
                            dateEndController.text = '';
                            FocusScope.of(context).unfocus();
                          })
                      : null,
                  onSaved: (val) {},
                  validator: (_) {
                    final val = selectedEndDate.value;
                    if (val == null) {
                      return 'Fecha final requerida';
                    }
                    final startDate = selectedStartDate.value;
                    if (startDate == null) {
                      return null;
                    }
                    if (val.isBefore(startDate)) {
                      return 'La fecha final no puede ser antes de la fecha inicial';
                    }
                    return null;
                  },
                  onTap: () async {
                    final previousDate = selectedEndDate.value ??
                        DateTime.now()
                            .copyWith(minute: 30)
                            .add(const Duration(hours: 1));
                    final newEndDate = await showDatePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 60)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      currentDate: DateTime.now(),
                      initialDate: previousDate,
                    );
                    if (!context.mounted || newEndDate == null) {
                      return;
                    }
                    final newEndTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(previousDate),
                    );
                    if (!context.mounted || newEndTime == null) {
                      return;
                    }
                    selectedEndDate.value = DateTime(
                      newEndDate.year,
                      newEndDate.month,
                      newEndDate.day,
                      newEndTime.hour,
                      newEndTime.minute,
                    );
                    dateEndController.text =
                        '${DateFormat.MMMd().format(selectedEndDate.value!)} ${DateFormat.jm().format(selectedEndDate.value!)}';
                    FocusScope.of(context).nextFocus();
                  },
                ),
                CustomFormField(
                  hintText: 'Lugar',
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Lugar requerido' : null,
                  onSaved: (val) => placeController.text = val ?? '',
                ),
                CustomFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  minLines: 1,
                  hintText: 'Descripción',
                  validator: (val) => null,
                  onSaved: (val) => textController.text = val ?? '',
                ),
                FilledButton(
                  onPressed: () async {
                    formKey.currentState!.save();
                    if (!formKey.currentState!.validate()) return;
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
          ),
        ));
  }
}
