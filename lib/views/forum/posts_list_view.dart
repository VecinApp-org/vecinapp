import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/entities/post.dart';

class PostsListView extends StatelessWidget {
  const PostsListView({super.key, required this.posts});
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts.elementAt(index);
        return Card(
          child: ListTile(
            title: Column(
              children: [
                Text(post.authorName),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(post.text)],
            ),
          ),
        );
      },
    );
  }
}
