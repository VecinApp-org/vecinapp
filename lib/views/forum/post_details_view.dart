import 'package:flutter/material.dart';
import 'package:vecinapp/utilities/entities/post_plus.dart';
import 'package:vecinapp/utilities/extensions/formatting/format_date_time.dart';
import 'package:vecinapp/utilities/widgets/custom_card.dart';
import 'package:vecinapp/utilities/widgets/expandable_text.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';

class PostDetailsView extends StatelessWidget {
  const PostDetailsView({super.key, required this.postWithUser});

  final PostPlus postWithUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostHeader(postWithUser: postWithUser),
              PostBody(postWithUser: postWithUser),
              PostComments(postWithUser: postWithUser),
            ],
          ),
        ),
      ),
    );
  }
}

class PostHeader extends StatelessWidget {
  const PostHeader({super.key, required this.postWithUser});
  final PostPlus postWithUser;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(postWithUser.user.displayName),
      subtitle: Text(
        formatDateTime(postWithUser.post.timestamp),
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
      leading: ProfilePicture(
        radius: 16,
        imageUrl: postWithUser.user.photoUrl,
      ),
      dense: true,
      visualDensity: VisualDensity(
          vertical: VisualDensity.minimumDensity,
          horizontal: VisualDensity.minimumDensity),
    );
  }
}

class PostBody extends StatelessWidget {
  const PostBody({super.key, required this.postWithUser});
  final PostPlus postWithUser;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ExpandableText(
        text: postWithUser.post.text,
        initialMaxLines: 50,
      ),
    );
  }
}

class PostComments extends StatelessWidget {
  const PostComments({super.key, required this.postWithUser});
  final PostPlus postWithUser;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
