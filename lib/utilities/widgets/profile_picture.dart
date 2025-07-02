import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';

class ProfilePicture extends HookWidget {
  const ProfilePicture({super.key, this.radius = 40, this.id, this.image});

  final Uint8List? image;
  final double radius;
  final String? id;

  @override
  Widget build(BuildContext context) {
    final profilePicture =
        useMemoized(() => context.watch<AppBloc>().profilePicture(userId: id));
    late final ImageProvider<Object>? imageData;
    if (image != null) {
      imageData = Image.memory(image!).image;
    } else {
      final result = useStream(profilePicture);
      if (result.hasData) {
        imageData = Image.memory(result.data!).image;
      } else {
        imageData = null;
      }
    }
    return CircleAvatar(
      radius: radius,
      foregroundImage: imageData,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      child: Icon(
        Icons.person_2_rounded,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        size: radius * 1.5,
      ),
    );
  }
}
