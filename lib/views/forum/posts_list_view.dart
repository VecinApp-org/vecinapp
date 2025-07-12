import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/post.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';
import 'package:vecinapp/utilities/widgets/expandable_text.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class PostsListView extends HookWidget {
  const PostsListView({
    super.key,
    required this.posts,
  });
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AppBloc>().state.cloudUser!.id;
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
      shrinkWrap: true,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts.elementAt(index);
        if (users[post.authorId] == null) {
          return CustomCard();
        }

        return CustomCard(
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
              child: ExpandableText(
                text: post.text,
              ),
            ),
            PostCardFooter(
              post: post,
              userId: userId,
            ),
          ],
        ));
      },
    );
  }
}

class PostCardFooter extends StatelessWidget {
  const PostCardFooter({super.key, required this.post, required this.userId});

  final Post post;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final likes = post.likes?.length ?? 0;
    final isLiked = post.likes?.contains(userId) ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          Text('${post.commentCount}',
              style: Theme.of(context).textTheme.bodySmall),
          IconButton(
            onPressed: () {
              if (isLiked) {
                context
                    .read<AppBloc>()
                    .add(AppEventUnlikePost(postId: post.id));
              } else {
                context.read<AppBloc>().add(AppEventLikePost(postId: post.id));
              }
            },
            icon: (!isLiked)
                ? const Icon(Icons.favorite_border)
                : const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
          ),
          Text('$likes', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
