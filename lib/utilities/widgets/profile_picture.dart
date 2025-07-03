import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ProfilePicture extends HookWidget {
  const ProfilePicture({super.key, this.radius = 40, required this.image});

  final Uint8List? image;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      foregroundImage: (image != null) ? Image.memory(image!).image : null,
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
