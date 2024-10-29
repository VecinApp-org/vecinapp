import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key, required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    const Icon icon = Icon(Icons.person);
    final profilePicture = context.watch<AppBloc>().profilePicture();
    return FutureBuilder(
        future: profilePicture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasData) {
                return CircleAvatar(
                  backgroundImage: Image.memory(snapshot.data!).image,
                  radius: radius,
                );
              } else {
                return CircleAvatar(
                  radius: radius,
                  child: icon,
                );
              }
            default:
              return CircleAvatar(
                radius: radius,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.0,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              );
          }
        });
  }
}
