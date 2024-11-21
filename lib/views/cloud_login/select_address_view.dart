import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';

enum AppBarActions { logout }

class SelectAddressView extends HookWidget {
  const SelectAddressView({super.key});
  @override
  Widget build(BuildContext context) {
    final countryController = useTextEditingController(text: 'Mexico');
    final stateController = useTextEditingController();
    final municipalityController = useTextEditingController();
    final postalCodeController = useTextEditingController();
    final neighborhoodController = useTextEditingController();
    final streetLine1Controller = useTextEditingController();
    final interiorController = useTextEditingController();
    final latitudeController = useValueNotifier<double?>(null);
    final longitudeController = useValueNotifier<double?>(null);
    return Scaffold(
      appBar: AppBar(
        title: Text('🇲🇽', style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          PopupMenuButton<AppBarActions>(
            onSelected: (value) {
              switch (value) {
                case AppBarActions.logout:
                  context.read<AppBloc>().add(const AppEventLogOut());
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AppBarActions.logout,
                child: Text('Cerrar Sesión'),
              )
            ],
          )
        ],
      ),
      body: CenteredView(children: [
        //show title
        Text('Selecciona tu dirección',
            style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: 8),
        Text(
          'La utilizaremos para encontrar tu vecindad',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 55),
        Row(
          children: [
            Expanded(
              child: TextField(
                  controller: streetLine1Controller,
                  decoration: InputDecoration(labelText: 'Calle y Número')),
            ),
          ],
        ),
        TextField(
            controller: interiorController,
            decoration: InputDecoration(labelText: 'Interior (Opcional)')),
        TextField(
            controller: neighborhoodController,
            decoration: InputDecoration(labelText: 'Colonia')),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: municipalityController,
                decoration: InputDecoration(labelText: 'Municipio'),
              ),
            ),
          ],
        ),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: postalCodeController,
                  decoration: InputDecoration(labelText: 'Código Postal'))),
          SizedBox(width: 13),
          Expanded(
            child: TextField(
              controller: stateController,
              decoration: InputDecoration(labelText: 'Estado'),
            ),
          ),
        ]),
        SizedBox(height: 55),
        FilledButton(
            onPressed: () => context.read<AppBloc>().add(
                AppEventUpdateHomeAddress(
                    country: countryController.text.trim(),
                    state: stateController.text.trim(),
                    municipality: municipalityController.text.trim(),
                    neighborhood: neighborhoodController.text.trim(),
                    postalCode: postalCodeController.text.trim(),
                    streetLine1: streetLine1Controller.text.trim(),
                    interior: interiorController.text.trim(),
                    latitude: latitudeController.value,
                    longitude: longitudeController.value)),
            child: const Text('Continuar')),
      ]),
    );
  }
}
