import 'package:flutter/material.dart';
import 'package:vecinapp/services/cloud/cloud_user.dart';

class UserListView extends StatelessWidget {
  final Iterable<CloudUser> users;
  const UserListView({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users.elementAt(index);
        return Column(
          children: [
            ListTile(
              onTap: () {},
              title: Text(
                user.displayName,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
