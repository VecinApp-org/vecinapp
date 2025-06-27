import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/views/forum/posts_list_view.dart';

class ForumView extends HookWidget {
  const ForumView({super.key, required, required this.cloudUser});
  final CloudUser cloudUser;
  @override
  Widget build(BuildContext context) {
    //get posts
    final stream = useMemoized(() => context.watch<AppBloc>().posts);
    final snapshot = useStream(stream);
    //check if snapshot is null
    if (snapshot.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final posts = snapshot.data!.toList();
    //sort posts
    posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
        appBar: AppBar(
          title: Text('Foro'),
          actions: [
            IconButton(
                onPressed: () {
                  context
                      .read<AppBloc>()
                      .add(const AppEventGoToCreatePostView());
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: (posts.isEmpty)
            ? const Center(child: Text('No hay eventos'))
            : ListView(
                shrinkWrap: true,
                children: [PostsListView(posts: posts)],
              ));
  }
}
