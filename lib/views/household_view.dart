import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/views/user_list_view.dart';

class HouseholdView extends HookWidget {
  const HouseholdView({super.key, required this.household});
  final Household household;

  @override
  Widget build(BuildContext context) {
    final stream = useMemoized(() =>
        context.watch<AppBloc>().householdNeighbors(householdId: household.id));
    final users = useStream(stream).data ?? [];
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
      body: Column(
        children: [
          Text('${household.street} #${household.number}',
              style: Theme.of(context).textTheme.titleLarge),
          Text(
              '${household.postalCode} ${household.municipality}, ${household.state}, ${household.country}'),
          const SizedBox(height: 20),
          Expanded(child: UserListView(users: users))
        ],
      ),
    );
  }
}

enum AddressActions {
  changeAddress,
}
