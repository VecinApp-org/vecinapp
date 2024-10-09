import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vecinapp/utilities/loading/loading_screen.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_state.dart';
import 'package:vecinapp/views/home_view.dart';
import 'package:vecinapp/views/login/forgot_password_view.dart';
import 'package:vecinapp/views/login/login_view.dart';
import 'package:vecinapp/views/login/register_view.dart';
import 'package:vecinapp/views/login/verify_email_view.dart';

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
        } else if (state is AppStateLoggedIn) {
          return const HomeView();
        } else {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
