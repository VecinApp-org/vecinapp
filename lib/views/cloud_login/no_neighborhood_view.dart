import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';

class NoNeighborhoodView extends StatelessWidget {
  const NoNeighborhoodView({super.key});
  @override
  Widget build(BuildContext context) {
    context.read<AppBloc>().add(const AppEventLookForNeighborhood());
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<AddressActions>(
            onSelected: (value) {
              switch (value) {
                case AddressActions.changeAddress:
                  context.read<AppBloc>().add(const AppEventExitHousehold());
                  break;
                case AddressActions.logOut:
                  context.read<AppBloc>().add(const AppEventLogOut());
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AddressActions.changeAddress,
                child: Text('Salir de la casa'),
              ),
              const PopupMenuItem(
                value: AddressActions.logOut,
                child: Text('Cerrar Sesión'),
              )
            ],
          )
        ],
      ),
      body: CenteredView(
        children: [
          Text(
            'Sin Vecindad',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 55),
          TextButton(
              onPressed: () => context
                  .read<AppBloc>()
                  .add(const AppEventLookForNeighborhood()),
              child: const Text('Reintentar'))
        ],
      ),
    );
  }
}

enum AddressActions {
  changeAddress,
  logOut,
}
