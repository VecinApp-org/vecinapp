import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';

class UserListView extends HookWidget {
  final Iterable<CloudUser> users;
  const UserListView({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final Set<String> authorIds = users.map((user) => user.id).toSet();
    Map<String, Uint8List?> profilePictures = {};
    for (String authorId in authorIds) {
      final stream = useMemoized(
          () => context.watch<AppBloc>().profilePicture(userId: authorId));
      profilePictures[authorId] = useStream(stream).data;
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users.elementAt(index);
        return Column(
          children: [
            ListTile(
              leading: ProfilePicture(
                image: profilePictures[user.id],
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
