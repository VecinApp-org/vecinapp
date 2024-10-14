import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/auth/auth_exceptions.dart';
import 'package:vecinapp/services/cloud/cloud_exceptions.dart';
import 'package:vecinapp/utilities/dialogs/show_error_dialog.dart';
import 'package:vecinapp/utilities/loading/loading_screen.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/views/delete_account_view.dart';
import 'package:vecinapp/views/home_view.dart';
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
              message = 'No se pudo crear el documento';
            } else if (exception is CouldNotDeleteRulebookException) {
              message = 'No se pudo borrar el documento';
            } else if (exception is CouldNotUpdateRulebooksException) {
              message = 'No se pudo actualizar el documento';
            } else if (exception is CouldNotGetRulebooksException) {
              message = 'No se pudieron obtener los reglamentos';
            } else if (exception is ChannelErrorRulebookException) {
              message = 'Los reglamentos deben tener título y contenido';
            } else {
              message = 'Error de almacenamiento desconocido';
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
        if (state is AppStateRegistering) {
          return const RegisterView();
        } else if (state is AppStateLoggingIn) {
          return const LoginView();
        } else if (state is AppStateResettingPassword) {
          return ForgotPasswordView(email: state.email);
        } else if (state is AppStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AppStateViewingHome) {
          return const HomeView();
        } else if (state is AppStateViewingProfile) {
          return const ProfileView();
        } else if (state is AppStateViewingSettings) {
          return SettingsView();
        } else if (state is AppStateViewingRulebooks) {
          return RulebooksView(rulebooks: state.rulebooks);
        } else if (state is AppStateEditingRulebook) {
          return EditRulebookView(rulebook: state.rulebook);
        } else if (state is AppStateViewingRulebookDetails) {
          return RulebookDetailsView(rulebook: state.rulebook);
        } else if (state is AppStateDeletingAccount) {
          return const DeleteAccountView();
        } else {
          return Container(); // This should never happen
        }
      },
    );
  }
}
