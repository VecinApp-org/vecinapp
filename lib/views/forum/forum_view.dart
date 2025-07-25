import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/views/forum/create_post_view.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import
import 'package:vecinapp/views/forum/posts_list_view.dart';

class ForumView extends HookWidget {
  const ForumView({super.key});
  @override
  Widget build(BuildContext context) {
    //get posts
    final stream = useMemoized(() => context.watch<AppBloc>().posts);
    final snapshot = useStream(stream);
    final posts = snapshot.data?.toList() ?? [];
    //sort posts
    posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    //gather data
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
        body: (snapshot.data == null)
            ? Container()
            : (snapshot.data!.isEmpty)
                ? const Center(child: Text('No hay publicaciones'))
                : PostsListView(posts: posts));
  }
}
