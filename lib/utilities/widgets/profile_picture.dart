import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key, this.radius = 40, this.id, this.image});

  final Uint8List? image;
  final double radius;
  final String? id;

  @override
  Widget build(BuildContext context) {
    final profilePicture = context.watch<AppBloc>().profilePicture(userId: id);
    return FutureBuilder(
      future: profilePicture,
      builder: (context, snapshot) {
        late final ImageProvider<Object>? imageData;
        if (image != null) {
          imageData = Image.memory(image!).image;
        } else {
          if (snapshot.hasData) {
            imageData = Image.memory(snapshot.data!).image;
          } else {
            imageData = null;
          }
        }

        return CircleAvatar(
          radius: radius,
          foregroundImage: imageData,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          child: Icon(
            Icons.person_2_rounded,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            size: radius * 1.5,
          ),
        );
      },
    );
  }
}
