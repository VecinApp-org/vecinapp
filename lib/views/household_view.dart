import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/views/user_list_view.dart';

class HouseholdView extends HookWidget {
  const HouseholdView({super.key, required this.householdId});

  final String householdId;

  @override
  Widget build(BuildContext context) {
    final stream = useMemoized(() =>
        context.watch<AppBloc>().householdNeighbors(householdId: householdId));
    final neighbors = useStream(stream);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.read<AppBloc>().add(const AppEventGoToProfileView()),
        ),
        actions: [
          PopupMenuButton<AddressActions>(
            onSelected: (value) {
              switch (value) {
                case AddressActions.changeAddress:
                  context.read<AppBloc>().add(AppEventExitHousehold());
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AddressActions.changeAddress,
                child: Text('Salir de la casa'),
              )
            ],
          )
        ],
      ),
      body: UserListView(
        users: neighbors.data ?? [],
      ),
    );
  }
}

enum AddressActions {
  changeAddress,
}
