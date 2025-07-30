import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/views/forum/create_post_view.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import
import 'package:vecinapp/views/forum/posts_list_view.dart';

class ForumView extends HookWidget {
  const ForumView({super.key});
  @override
  Widget build(BuildContext context) {
    useMemoized(
        () => context.read<AppBloc>().add(const AppEventRefreshPosts()));
    return Scaffold(
        appBar: AppBar(
          title: Text('Foro'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CreatePostView(),
                  ));
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: BlocBuilder<AppBloc, AppState>(
          buildWhen: (previous, current) =>
              previous.postsStatus != current.postsStatus ||
              previous.posts != current.posts,
          builder: (context, state) {
            switch (state.postsStatus!) {
              case PostsStatus.initial:
                devtools.log('BUILD: Posts initial');
                return Container();
              case PostsStatus.loading:
                devtools.log('BUILD: Posts loading');
                return const Center(child: CircularProgressIndicator());
              case PostsStatus.success:
                switch (state.posts!.isEmpty) {
                  case true:
                    devtools.log('BUILD: Empty posts');
                    return const Center(child: Text('No hay publicaciones'));
                  case false:
                    return PostsListView(posts: state.posts!);
                }
              case PostsStatus.failure:
                return const Center(
                    child: Text('Error al cargar las publicaciones'));
            }
          },
        ));
  }
}
