import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts.elementAt(index);
        return PostCard(post: post);
      },
    );
  }
}

class PostCard extends HookWidget {
  const PostCard({super.key, required this.post});
  final Post post;
  @override
  Widget build(BuildContext context) {
    final futureUser = context.watch<AppBloc>().userFromId(post.authorId);
    final resultUser = useFuture(futureUser);
    if (!resultUser.hasData) {
      return CustomCard();
    }
    return CustomCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: ProfilePicture(
            radius: 16,
            imageUrl: resultUser.data?.photoUrl,
          ),
          title: Text(
            resultUser.data?.displayName ?? '[Usuario no existe]',
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
        ),
      ],
    ));
  }
}

class PostCardFooter extends StatelessWidget {
  const PostCardFooter({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AppBloc>().state.cloudUser?.id;
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
