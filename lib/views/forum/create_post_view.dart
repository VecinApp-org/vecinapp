import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/widgets/custom_form_field.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';

class CreatePostView extends HookWidget {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final textController = useTextEditingController();
    return DocView(
        title: null,
        text: null,
        appBarTitle: 'Crear Publicación',
        appBarActions: [],
        appBarBackAction: () =>
            context.read<AppBloc>().add(const AppEventGoToPostsView()),
        children: [
          Form(
            key: formKey,
            child: Column(children: [
              CustomFormField(
                hintText: 'Escribe aquí.',
                autofocus: true,
                maxLength: 10000,
                minLines: 3,
                onSaved: (value) {
                  textController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio.';
                  }
                  return null;
                },
              ),
              FilledButton(
                onPressed: () {
                  formKey.currentState!.save();
                  if (formKey.currentState!.validate()) {
                    context
                        .read<AppBloc>()
                        .add(AppEventCreatePost(text: textController.text));
                  }
                },
                child: const Text('Publicar'),
              ),
            ]),
          ),
        ]);
  }
}
