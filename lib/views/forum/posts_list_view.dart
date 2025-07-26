import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/post.dart';
import 'package:vecinapp/utilities/entities/post_with_user.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';
import 'package:vecinapp/utilities/widgets/expandable_text.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

class PostsListView extends HookWidget {
  const PostsListView({
    super.key,
    required this.posts,
  });
  final List<PostWithUser> posts;

  @override
  Widget build(BuildContext context) {
    devtools.log('BUILD: PostsListView');
    final controller = useScrollController();
    const threshold = 300.0;

    useEffect(() {
      void onScroll() {
        if (!controller.hasClients) return;
        final maxScroll = controller.position.maxScrollExtent;
        final currentScroll = controller.position.pixels;
        if (maxScroll - currentScroll <= threshold) {
          context.read<AppBloc>().add(AppEventFetchMorePosts());
        }
      }

      controller.addListener(onScroll);
      return () => controller.removeListener(onScroll);
    }, [controller]);

    return ListView.builder(
        controller: controller,
        shrinkWrap: true,
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          return index < posts.length
              ? PostCard(postWithUser: posts[index])
              : const Center(child: CircularProgressIndicator());
        });
  }
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.postWithUser});
  final PostWithUser postWithUser;
  @override
  Widget build(BuildContext context) {
    final post = postWithUser.post;
    final user = postWithUser.user;
    return CustomCard(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: ProfilePicture(
            radius: 16,
            imageUrl: user.photoUrl,
          ),
          title: Text(
            user.displayName,
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

class PostCardFooter extends HookWidget {
  const PostCardFooter({super.key, required this.post});
  final Post post;
  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AppBloc>().state.cloudUser!.id;
    final likes = post.likeCount;
    final isLiked = post.likes.contains(userId);
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
