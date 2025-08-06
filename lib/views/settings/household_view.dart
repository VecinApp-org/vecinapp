import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/utilities/entities/cloud_household.dart';
import 'package:vecinapp/utilities/widgets/user_list_view.dart';

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
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) {
        if (!state.isLoading && state.cloudUser?.householdId == null) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(
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
        body: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 21.0, vertical: 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, size: 34),
                  const SizedBox(height: 21),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Miembros',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            UserListView(users: users)
          ],
        ),
      ),
    );
  }
}

enum AddressActions {
  changeAddress,
}
