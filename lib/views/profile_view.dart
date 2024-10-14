import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/bloc/app_state.dart';

import 'dart:developer' as devtools show log;

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(const AppEventGoToHomeView());
          },
        ),
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          devtools.log(state.toString());
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 32),
              Container(
                width: 120,
                height: 120,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: Image.network(
                  state.user?.photoUrl ?? '',
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/images/flutter_logo.png');
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(state.user?.displayName ?? 'Sin Nombre',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.alternate_email),
                title: Text(state.user?.email ?? 'Sin email'),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title:
                    Text(state.user?.phoneNumber ?? 'Sin número de teléfono'),
              ),
              const ListTile(
                leading: Icon(Icons.home),
                title: Text('Sin Dirección'),
              ),
              const Divider(),
              ListTile(
                  title: const Text('Configuración'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    context
                        .read<AppBloc>()
                        .add(const AppEventGoToSettingsView());
                  }),
            ],
          );
        },
      ),
    );
  }
}
