import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/geocoding/address.dart';

class ConfirmAddressView extends StatelessWidget {
  const ConfirmAddressView({super.key, required this.addresses});

  final List<Address> addresses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar dirección'),
        leading: BackButton(
          onPressed: () => context.read<AppBloc>().add(const AppEventReset()),
        ),
      ),
      body: ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return ListTile(
            title: Text(
                '${address.street} ${address.houseNumber} ${address.interior}'
                    .trim()),
            subtitle: Text(
              '${address.postalCode} ${address.municipality}, ${address.state}, ${address.country}',
            ),
            onTap: () => context.read<AppBloc>().add(
                  AppEventConfirmAddress(address: address),
                ),
          );
        },
      ),
    );
  }
}
