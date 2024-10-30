import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';

class NoNeighborhoodView extends StatelessWidget {
  const NoNeighborhoodView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AppBloc>().add(
          const AppEventLookForNeighborhood(),
        );
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sin Vecindad',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 55),
              TextButton(
                onPressed: () {
                  context.read<AppBloc>().add(
                        const AppEventLookForNeighborhood(),
                      );
                },
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
