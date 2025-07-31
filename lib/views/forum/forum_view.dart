import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/utilities/entities/post_with_user.dart';
import 'package:vecinapp/views/forum/create_post_view.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import
import 'package:vecinapp/views/forum/posts_list_view.dart';

class ForumView extends StatelessWidget {
  const ForumView({super.key});
  @override
  Widget build(BuildContext context) {
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
        body: BlocSelector<AppBloc, AppState, LoadStatus>(
          selector: (state) => state.postsStatus!,
          builder: (context, state) {
            switch (state) {
              case LoadStatus.initial:
                context.read<AppBloc>().add(const AppEventRefreshPosts());
                devtools.log('BUILD: Posts initial');
                return Container();
              case LoadStatus.loading:
                devtools.log('BUILD: Posts loading');
                return const Center(child: CircularProgressIndicator());
              case LoadStatus.success:
                return BlocSelector<AppBloc, AppState, List<PostWithUser>?>(
                    selector: (state) => state.posts,
                    builder: (context, state) {
                      switch (state!.isEmpty) {
                        case true:
                          devtools.log('BUILD: Empty posts');
                          return const Center(
                              child: Text('No hay publicaciones'));
                        case false:
                          return PostsListView(posts: state);
                      }
                    });
              case LoadStatus.failure:
                devtools.log('BUILD: Posts failure');
                return const Center(
                    child: Text('Error al cargar las publicaciones'));
            }
          },
        ));
  }
}
