import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/entities/cloud_user.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';
import 'package:vecinapp/utilities/widgets/profile_picture.dart';

class NoNeighborhoodView extends HookWidget {
  const NoNeighborhoodView(
      {super.key, required this.cloudUser, required this.household});
  final CloudUser cloudUser;
  final Household household;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 13.0),
              child: GestureDetector(
                  onTap: () => context
                      .read<AppBloc>()
                      .add(const AppEventGoToProfileView()),
                  child: ProfilePicture(
                    radius: 16,
                    imageUrl: cloudUser.photoUrl,
                  )))
        ],
      ),
      body: CenteredView(
        children: [
          Text(
            'Tu casa aún no está asociada a ninguna vecindad.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 55),
          FilledButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventLookForNeighborhood()),
              child: const Text('Buscar vecindad'))
        ],
      ),
    );
  }
}

enum AddressActions {
  changeAddress,
  logOut,
}
