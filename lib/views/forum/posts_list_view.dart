import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/post.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';
import 'package:vecinapp/views/forum/post_card_footer.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class PostsListView extends HookWidget {
  const PostsListView({super.key, required this.posts});
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    devtools.log('PostsListView.build');
    final List<String> authorIds =
        posts.map((post) => post.authorId).toSet().toList();
    Map<String, Uint8List?> profilePictures = {};
    Map<String, CloudUser?> users = {};
    for (String authorId in authorIds) {
      // load users
      final futureUser =
          useMemoized(() => context.watch<AppBloc>().userFromId(authorId));
      final resultUser = useFuture(futureUser);
      if (resultUser.hasData) {
        users[authorId] = resultUser.data as CloudUser;
      } else {
        users[authorId] = null;
      }
      // load profile pictures
      final future = useMemoized(
          () => context.watch<AppBloc>().profilePicture(userId: authorId));
      final result = useFuture(future);
      if (result.hasData) {
        profilePictures[authorId] = result.data;
      } else {
        profilePictures[authorId] = null;
      }
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts.elementAt(index);
        return Card(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
              ),
              title: Row(
                children: [
                  ProfilePicture(
                    radius: 16,
                    image: profilePictures[post.authorId],
                  ),
                  const SizedBox(width: 8),
                  Text(users[post.authorId]?.displayName ?? ''),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 0.0),
                    child: Text(post.text),
                  ),
                  PostCardFooter(
                    likesCount: post.likeCount,
                    commentsCount: post.commentCount,
                  ),
                ],
              ),
            ));
      },
    );
  }
}
