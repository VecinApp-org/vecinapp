import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/post.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';

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
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: FutureBuilder<CloudUser?>(
            future: context.watch<AppBloc>().userFromId(post.authorId),
            builder: (context, snapshot) {
              if (snapshot.data == null) return Container();
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    ProfilePicture(radius: 12, id: snapshot.data!.id),
                    const SizedBox(width: 8),
                    Text(snapshot.data!.displayName),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 0.0),
                  child: Text(post.text),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
