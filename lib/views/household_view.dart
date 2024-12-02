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
    late final String line1;
    if (household.interior == null) {
      line1 = '${household.street} #${household.number}';
    } else {
      line1 =
          '${household.street} #${household.number} Int.${household.interior}';
    }
    final line2 =
        '${household.neighborhood}, ${household.postalCode}, ${household.municipality}, ${household.state}, ${household.country}';
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
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 13.0, vertical: 55.0),
            child: Column(
              children: [
                Text(
                  line1,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  line2,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(child: UserListView(users: users))
        ],
      ),
    );
  }
}

enum AddressActions {
  changeAddress,
}
