import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/widgets/doc_view.dart';

class CreatePostView extends HookWidget {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    return DocView(
        title: null,
        text: null,
        appBarTitle: 'Crear Evento',
        appBarActions: [],
        appBarBackAction: () =>
            context.read<AppBloc>().add(const AppEventGoToPostsView()),
        more: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Contenido'),
          ),
          FilledButton(
            onPressed: () {
              context
                  .read<AppBloc>()
                  .add(AppEventCreatePost(text: textController.text));
            },
            child: const Text('Crear'),
          ),
        ]);
  }
}
