import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vecinapp/utilities/widgets/centered_view.dart';

class SelectAddressView extends HookWidget {
  const SelectAddressView({super.key});
  @override
  Widget build(BuildContext context) {
    final countryController = useTextEditingController(text: 'México');
    final stateController = useTextEditingController(text: 'Nuevo León');
    final municipalityController = useTextEditingController(text: 'Monterrey');
    final postalCodeController = useTextEditingController(text: '64790');
    final neighborhoodController = useTextEditingController(text: 'Las Brisas');
    final streetController = useTextEditingController(text: 'Puerto Soconusco');
    final numberController = useTextEditingController(text: '5422');
    final interiorController = useTextEditingController(text: '');
    final latitudeController = useValueNotifier<double>(25.671802609711552);
    final longitudeController = useValueNotifier<double>(-100.30939284155167);
    return CenteredView(children: [
      Text('Selecciona tu dirección',
          style: Theme.of(context).textTheme.headlineMedium),
      SizedBox(height: 55),
      Row(children: [
        Expanded(
            child: TextField(
                controller: countryController,
                decoration: InputDecoration(labelText: 'País'))),
        SizedBox(width: 13),
        Expanded(
            child: TextField(
                controller: stateController,
                decoration: InputDecoration(labelText: 'Estado')))
      ]),
      TextField(
          controller: municipalityController,
          decoration: InputDecoration(labelText: 'Municipio')),
      TextField(
          controller: neighborhoodController,
          decoration: InputDecoration(labelText: 'Colonia')),
      Row(
        children: [
          Expanded(
            child: TextField(
                controller: streetController,
                decoration: InputDecoration(labelText: 'Calle')),
          ),
          SizedBox(width: 13),
        ],
      ),
      Row(children: [
        Expanded(
          child: TextField(
              controller: numberController,
              decoration: InputDecoration(labelText: 'Número')),
        ),
        SizedBox(width: 13),
        Expanded(
            child: TextField(
                controller: interiorController,
                decoration: InputDecoration(labelText: 'Interior'))),
        SizedBox(width: 13),
        Expanded(
            child: TextField(
                controller: postalCodeController,
                decoration: InputDecoration(labelText: 'Código Postal')))
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
                  street: streetController.text.trim(),
                  houseNumber: numberController.text.trim(),
                  interior: interiorController.text.trim(),
                  latitude: latitudeController.value,
                  longitude: longitudeController.value)),
          child: const Text('Continuar')),
    ]);
  }
}
