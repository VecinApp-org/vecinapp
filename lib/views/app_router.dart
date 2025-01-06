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
import 'package:vecinapp/views/delete_account_view.dart';
import 'package:vecinapp/views/household_view.dart';
import 'package:vecinapp/views/neighborhood_view.dart';
import 'package:vecinapp/views/login/forgot_password_view.dart';
import 'package:vecinapp/views/login/login_view.dart';
import 'package:vecinapp/views/login/register_view.dart';
import 'package:vecinapp/views/login/verify_email_view.dart';
import 'package:vecinapp/views/profile_view.dart';
import 'package:vecinapp/views/rulebooks/edit_rulebook_view.dart';
import 'package:vecinapp/views/rulebooks/rulebook_details_view.dart';
import 'package:vecinapp/views/rulebooks/rulebooks_view.dart';
import 'package:vecinapp/views/settings_view.dart';
import 'dart:developer' as devtools show log;

import 'package:vecinapp/views/splash_view.dart';

class AppBlocRouter extends StatelessWidget {
  const AppBlocRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
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
          devtools.log(exception.toString());
          devtools.log(exception.hashCode.toString());
          String message = exception.toString();
          if (exception is AuthException) {
            if (exception is GenericAuthException) {
              message = 'Error de autenticación';
            } else if (exception is InvalidCredentialAuthException) {
              message = 'La combinación de correo y contraseña es incorrecta';
            } else if (exception is EmailAlreadyInUseAuthException) {
              message = 'El correo ya se encuentra registrado';
            } else if (exception is WeakPasswordAuthException) {
              message = 'La contraseña es muy débil';
            } else if (exception is InvalidEmailAuthException) {
              message = 'El correo está mal escrito';
            } else if (exception
                is PasswordConfirmationDoesNotMatchAuthException) {
              message = 'Las contraseñas no coinciden';
            } else if (exception is RequiresRecentLoginAuthException) {
              message = 'Debes iniciar sesión antes de realizar esta operación';
            } else if (exception is TooManyRequestsAuthException) {
              message = 'Demasiados intentos de inicio de sesión';
            } else if (exception is NetworkRequestFailedAuthException) {
              message = 'No hay internet';
            } else if (exception is UserNotLoggedInAuthException) {
              message = 'Debes iniciar sesión antes de realizar esta operación';
            } else if (exception is UserNotVerifiedAuthException) {
              message = 'Aún no has verificado tu correo';
            } else if (exception is ChannelErrorAuthException) {
              message = 'Dejaste algo vacío';
            }
          } else if (exception is CloudException) {
            if (exception is CouldNotCreateRulebooksException) {
              message = 'No se pudo crear, intenta de nuevo';
            } else if (exception is CouldNotDeleteRulebookException) {
              message = 'No se pudo borrar. Intenta de nuevo';
            } else if (exception is CouldNotUpdateRulebooksException) {
              message = 'No se pudo actualizar';
            } else if (exception is CouldNotGetRulebooksException) {
              message = 'No se pudo obtener la información';
            } else if (exception is ChannelErrorCloudException) {
              message = 'Dejaste algo vacío';
            } else {
              message = 'Error de base de datos';
            }
          } else if (exception is StorageException) {
            if (exception is ImageTooLargeStorageException) {
              message = 'La imagen es demasiado grande';
            } else if (exception is CouldNotUploadImageStorageException) {
              message = 'No se pudo cargar la imagen';
            } else if (exception is GenericStorageException) {
              message = 'Error de almacenamiento';
            } else if (exception is ImageNotFoundStorageException) {
              message = 'No se pudo cargar la imagen';
            } else if (exception is ImageTooLargeStorageException) {
              message = 'Esa imagen es demasiado grande';
            } else if (exception is CouldNotDeleteImageStorageException) {
              message = 'No se pudo borrar la imagen';
            } else {
              message = 'Error de almacenamiento desconocido';
            }
          } else if (exception is GeocodingException) {
            if (exception is ChannelErrorGeocodingException) {
              message = 'Dejaste algo vacío';
            } else if (exception is NoValidAddressFoundGeocodingException) {
              message = 'No se encontraron resultados';
            } else if (exception is GenericGeocodingException) {
              message = 'Error de geocodificación';
            } else {
              message = 'Error de geocodificación desconocido';
            }
          } else {
            message = 'Error mitológico';
          }
          showErrorDialog(
            text: message,
            context: context,
          );
        }
      },
      builder: (context, state) {
        devtools.log(state.runtimeType.toString());
        if (state is AppStateUnInitalized) {
          return const SplashView();
        } else if (state is AppStateRegistering) {
          return const RegisterView();
        } else if (state is AppStateLoggingIn) {
          return const LoginView();
        } else if (state is AppStateResettingPassword) {
          return ForgotPasswordView(email: state.email);
        } else if (state is AppStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AppStateViewingNeighborhood) {
          return NeighborhoodView(
            neighborhood: state.neighborhood!,
          );
        } else if (state is AppStateViewingProfile) {
          return ProfileView(
            cloudUser: state.cloudUser!,
            household: state.household,
          );
        } else if (state is AppStateViewingHousehold) {
          return HouseholdView(
            household: state.household!,
          );
        } else if (state is AppStateViewingSettings) {
          return SettingsView();
        } else if (state is AppStateViewingRulebooks) {
          return RulebooksView(
            cloudUser: state.cloudUser!,
          );
        } else if (state is AppStateEditingRulebook) {
          return EditRulebookView(rulebook: state.rulebook);
        } else if (state is AppStateViewingRulebookDetails) {
          return RulebookDetailsView(
              rulebook: state.rulebook, cloudUser: state.cloudUser!);
        } else if (state is AppStateDeletingAccount) {
          return const DeleteAccountView();
        } else if (state is AppStateCreatingCloudUser) {
          return const RegisterCloudUserView();
        } else if (state is AppStateSelectingHomeAddress) {
          return const SelectAddressView();
        } else if (state is AppStateNoNeighborhood) {
          return const NoNeighborhoodView();
        } else if (state is AppStateConfirmingHomeAddress) {
          return ConfirmAddressView(addresses: state.addresses);
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
