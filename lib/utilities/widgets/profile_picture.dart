import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key, this.radius = 40, required this.imageUrl});
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return EmptyAvatar(radius: radius);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: radius * 2,
      height: radius * 2,
      errorWidget: (context, url, error) => EmptyAvatar(radius: radius),
      imageBuilder: (context, imageProvider) => CircleAvatar(
        foregroundImage: imageProvider,
        radius: radius,
      ),
    );
  }
}

class EmptyAvatar extends StatelessWidget {
  const EmptyAvatar({super.key, this.radius = 40});
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person_2_rounded,
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        size: radius * 1.3,
      ),
    );
  }
}
