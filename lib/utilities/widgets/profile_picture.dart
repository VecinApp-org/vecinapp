import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';

import 'package:flutter_hooks/flutter_hooks.dart';

class ProfilePicture extends HookWidget {
  const ProfilePicture({super.key, required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(() => context.watch<AppBloc>().profilePicture());
    final profilePicture = useStream(future, preserveState: false);
    if (profilePicture.data != null) {
      return CircleAvatar(
        backgroundImage: MemoryImage(profilePicture.data!),
        radius: radius,
      );
    } else {
      return CircleAvatar(
        radius: radius,
      );
    }
  }
}
