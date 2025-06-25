import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/entities/neighborhood.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

import 'package:vecinapp/utilities/widgets/profile_picture.dart'; // ignore: unused_import

class ForumView extends HookWidget {
  const ForumView(
      {super.key, required this.cloudUser, required this.neighborhood});
  final CloudUser cloudUser;
  final Neighborhood neighborhood;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: Text(
          neighborhood.neighborhoodName,
        ),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 13.0),
              child: GestureDetector(
                  onTap: () => context
                      .read<AppBloc>()
                      .add(const AppEventGoToProfileView()),
                  child: ProfilePicture(
                    radius: 16,
                    id: cloudUser.id,
                  )))
        ],
      ),
      body: Center(
        child: Text(
          'Foro WIP',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
