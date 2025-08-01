import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/cloud/cloud_exceptions.dart';
import 'package:vecinapp/services/geocoding/geocoding_exceptions.dart';
import 'package:vecinapp/services/storage/storage_exceptions.dart';
import 'package:vecinapp/utilities/dialogs/show_error_dialog.dart';
import 'package:vecinapp/utilities/loading/loading_screen.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/views/cloud_login/confirm_address_view.dart';
import 'package:vecinapp/views/cloud_login/select_address_view.dart';
import 'package:vecinapp/views/cloud_login/no_neighborhood_view.dart';
import 'package:vecinapp/views/cloud_login/register_cloud_user_view.dart';
import 'package:vecinapp/views/login/welcome_view.dart';
import 'package:vecinapp/views/login/verify_email_view.dart';
import 'package:vecinapp/views/neighborhood_view.dart';
import 'dart:developer' as devtools show log; // ignore: unused_import

import 'package:vecinapp/views/splash_view.dart';

class AppBlocRouter extends StatelessWidget {
  const AppBlocRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listenWhen: (previous, current) {
        return (previous.isLoading != current.isLoading ||
            previous.loadingText != current.loadingText ||
            previous.exception != current.exception);
      },
      listener: (context, state) {
        if (!state.isLoading) {
          LoadingScreen().hide();
        } else {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? '',
          );
        }
        // show error dialog
        final exception = state.exception;
        if (exception != null) {
          devtools.log(
              'State exception: ${exception.toString()} + ${exception.hashCode.toString()}');
          String message = 'Error mitológico';
          if (exception is AuthException) {
            message = exception.message;
          } else if (exception is CloudException) {
            message = exception.message;
          } else if (exception is StorageException) {
            message = exception.message;
          } else if (exception is GeocodingException) {
            message = exception.message;
          }
          showErrorDialog(
            text: message,
            context: context,
          );
        }
      },
      buildWhen: (previous, current) {
        return (previous.runtimeType != current.runtimeType);
      },
      builder: (context, state) {
        if (state is AppStateUnInitalized) {
          return const SplashView();
        } else if (state is AppStateLoggedOut) {
          return const WelcomeView();
        } else if (state is AppStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AppStateCreatingCloudUser) {
          return const RegisterCloudUserView();
        } else if (state is AppStateSelectingHomeAddress) {
          return const SelectAddressView();
        } else if (state is AppStateNoNeighborhood) {
          return NoNeighborhoodView(
            cloudUser: state.cloudUser!,
            household: state.household!,
          );
        } else if (state is AppStateConfirmingHomeAddress) {
          return ConfirmAddressView(addresses: state.addresses);
        } else if (state is AppStateNeighborhood) {
          return NeighborhoodView(
            cloudUser: state.cloudUser!,
            neighborhood: state.neighborhood!,
            household: state.household!,
          );
        } else if (state is AppStateError) {
          return const BadState();
        } else {
          return const BadState(); // This should never happen
        }
      },
    );
  }
}

class BadState extends StatelessWidget {
  const BadState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ocurrió un error',
                style: Theme.of(context).textTheme.headlineSmall),
            TextButton(
                onPressed: () =>
                    context.read<AppBloc>().add(const AppEventReset()),
                child: const Text('Reiniciar'))
          ],
        ),
      ),
    );
  }
}
