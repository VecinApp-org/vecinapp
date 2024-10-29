import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';

class SelectAddressView extends StatelessWidget {
  const SelectAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selecciona tu dirección',
                  style: Theme.of(context).textTheme.headlineLarge),
              TextButton(
                onPressed: () {
                  context.read<AppBloc>().add(
                        const AppEventUpdateHomeAddress(
                          country: 'Mexico',
                          state: 'Nuevo León',
                          municipality: 'Monterrey',
                          postalCode: '60000',
                          street: 'Calle 1',
                          number: '123',
                          interior: '1',
                          latitude: 20.0,
                          longitude: 20.0,
                        ),
                      );
                },
                child: const Text('Set address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
