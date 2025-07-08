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
    final Set<String> authorIds = posts.map((post) => post.authorId).toSet();
    Map<String, CloudUser?> users = {};
    for (String authorId in authorIds) {
      // load users
      final futureUser =
          useMemoized(() => context.watch<AppBloc>().userFromId(authorId));
      final resultUser = useFuture(futureUser);
      if (resultUser.hasData) {
        users[authorId] = resultUser.data as CloudUser;
      } else {
        if (resultUser.connectionState == ConnectionState.done) {
          users[authorId] = CloudUser(
              id: authorId,
              displayName: '[Usuario no existe]',
              householdId: null,
              neighborhoodId: null,
              photoUrl: null,
              isNeighborhoodAdmin: false,
              isSuperAdmin: false);
        } else {
          users[authorId] = null;
        }
      }
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts.elementAt(index);

        if (users[post.authorId] == null) {
          return Card(
            child: SizedBox(
              height: 100,
            ),
          );
        }

        return Card(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: ProfilePicture(
                    radius: 16,
                    imageUrl: users[post.authorId]?.photoUrl,
                  ),
                  title: Text(
                    users[post.authorId]?.displayName ?? '[Usuario no existe]',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    post.text,
                    textAlign: TextAlign.left,
                  ),
                ),
                PostCardFooter(
                  likesCount: post.likeCount,
                  commentsCount: post.commentCount,
                ),
              ],
            ));
      },
    );
  }
}
