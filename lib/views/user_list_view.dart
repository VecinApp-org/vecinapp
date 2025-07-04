import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';

class UserListView extends HookWidget {
  final Iterable<CloudUser> users;
  const UserListView({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users.elementAt(index);
        return Column(
          children: [
            ListTile(
              leading: ProfilePicture(
                imageUrl: user.photoUrl,
                radius: 21.0,
              ),
              trailing: user.isNeighborhoodAdmin
                  ? Chip(
                      label: Text(
                        'Admin',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  : null,
              onTap: () {},
              title: Text(
                user.displayName,
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
