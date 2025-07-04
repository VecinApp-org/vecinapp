import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ProfilePicture extends HookWidget {
  const ProfilePicture({super.key, this.radius = 40, required this.imageUrl});
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        child: Icon(
          Icons.person_2_rounded,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          size: radius * 1.5,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      width: radius * 2,
      height: radius * 2,
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        child: Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          size: radius * 1.5,
        ),
      ),
      imageBuilder: (context, imageProvider) => CircleAvatar(
        foregroundImage: imageProvider,
        radius: radius,
      ),
    );
  }
}
