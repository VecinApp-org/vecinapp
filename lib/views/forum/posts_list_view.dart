import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/extensions/formatting/format_date_time.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/post_plus.dart';
import 'package:vecinapp/utilities/widgets/Infinite_list_builder.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';
import 'package:vecinapp/utilities/widgets/expandable_text.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';
import 'dart:developer' as devtools show log;
import 'package:vecinapp/views/forum/show_post_comments.dart'; // ignore: unused_import

class PostsListView extends StatelessWidget {
  const PostsListView({
    super.key,
    required this.posts,
  });
  final List<PostPlus> posts;

  @override
  Widget build(BuildContext context) {
    final hasReachedMax = context.watch<AppBloc>().state.hasReachedMaxPosts!;
    devtools.log('BUILD: PostsListView');
    return RefreshIndicator(
      onRefresh: () {
        Future block = context.read<AppBloc>().stream.first;
        context.read<AppBloc>().add(AppEventRefreshPosts());
        return block;
      },
      child: InfiniteListBuilder(
          fetchmore: () =>
              context.read<AppBloc>().add(AppEventFetchMorePosts()),
          itemCount: posts.length + 1,
          itemBuilder: (context, index) {
            return index < posts.length
                ? PostCard(postWithUser: posts[index])
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: (hasReachedMax)
                            ? Text('No hay más posts')
                            : CircularProgressIndicator()),
                  );
          }),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.postWithUser});
  final PostPlus postWithUser;
  @override
  Widget build(BuildContext context) {
    final post = postWithUser.post;
    return CustomCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostCardHeader(postWithUser: postWithUser),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ExpandableText(
            text: post.text,
          ),
        ),
        PostCardFooter(postWithUser: postWithUser),
      ],
    ));
  }
}

class PostCardHeader extends HookWidget {
  const PostCardHeader({super.key, required this.postWithUser});
  final PostPlus postWithUser;
  @override
  Widget build(BuildContext context) {
    final post = postWithUser.post;
    final user = postWithUser.user;
    return ListTile(
      leading: ProfilePicture(
        radius: 16,
        imageUrl: user.photoUrl,
      ),
      title: Text(
        user.displayName,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        formatDateTime(post.timestamp),
      ),
      dense: true,
      visualDensity: VisualDensity(
          vertical: VisualDensity.minimumDensity,
          horizontal: VisualDensity.minimumDensity),
    );
  }
}

class PostCardFooter extends HookWidget {
  const PostCardFooter({super.key, required this.postWithUser});
  final PostPlus postWithUser;
  @override
  Widget build(BuildContext context) {
    final post = postWithUser.post;
    final userId = context.watch<AppBloc>().state.cloudUser!.id;
    final likes = post.likeCount;
    final isLiked = post.likes.contains(userId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              showPostComments(context: context, post: post);
            },
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
