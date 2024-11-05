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
    final countryController = useTextEditingController();
    final stateController = useTextEditingController();
    final municipalityController = useTextEditingController();
    final postalCodeController = useTextEditingController();
    final streetController = useTextEditingController();
    final numberController = useTextEditingController();
    final interiorController = useTextEditingController();
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
      Row(
        children: [
          Expanded(
            child: TextField(
                controller: streetController,
                decoration: InputDecoration(labelText: 'Calle')),
          ),
          SizedBox(width: 13),
          Expanded(
            child: TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: 'Número')),
          ),
        ],
      ),
      Row(children: [
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
      TextButton(
          onPressed: () => context.read<AppBloc>().add(
              AppEventUpdateHomeAddress(
                  country: countryController.text.trim(),
                  state: stateController.text.trim(),
                  municipality: municipalityController.text.trim(),
                  postalCode: postalCodeController.text.trim(),
                  street: streetController.text.trim(),
                  houseNumber: numberController.text.trim(),
                  interior: interiorController.text.trim(),
                  latitude: 25.671802609711552,
                  longitude: -100.30939284155167)),
          child: const Text('Continuar')),
      TextButton(
          onPressed: () => context.read<AppBloc>().add(
              AppEventUpdateHomeAddress(
                  country: 'México',
                  state: 'Nuevo León',
                  municipality: 'Monterrey',
                  postalCode: '64000',
                  street: 'Ignacio Zaragoza',
                  houseNumber: '123',
                  interior: 'A',
                  latitude: 25.671802609711552,
                  longitude: -100.30939284155167)),
          child: const Text('Set default address'))
    ]);
  }
}
