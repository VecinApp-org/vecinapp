import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({super.key, required this.radius, required this.id});

  final double radius;
  final String id;

  @override
  Widget build(BuildContext context) {
    final profilePicture = context.watch<AppBloc>().profilePicture(userId: id);
    return FutureBuilder(
      future: profilePicture,
      builder: (context, snapshot) {
        if (snapshot.data != null &&
            snapshot.connectionState == ConnectionState.done) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: Image.memory(snapshot.data!).image,
          );
        } else {
          return CircleAvatar(
            radius: radius,
          );
        }
      },
    );
  }
}
