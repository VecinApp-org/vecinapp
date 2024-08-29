import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/helpers/loading/loading_screen.dart';
import 'package:vecinapp/services/auth/bloc/auth_bloc.dart';
import 'package:vecinapp/services/auth/bloc/auth_event.dart';
import 'package:vecinapp/services/auth/bloc/auth_state.dart';
import 'package:vecinapp/services/auth/firebase_auth_provider.dart';
import 'package:vecinapp/views/home/docs/edit_doc_view.dart';
import 'package:vecinapp/views/home/home_drawer.dart';
import 'package:vecinapp/views/login/login_view.dart';
import 'package:vecinapp/views/login/verify_email_view.dart';
import 'services/settings/settings_controller.dart';
import 'views/home/settings_view.dart';
import 'views/login/register_view.dart';
import 'dart:developer' as devtools show log;

class VecinApp extends StatelessWidget {
  const VecinApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    devtools.log('MaterialApp');
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'vecinapp',
          //Theme
          theme: ThemeData(useMaterial3: true),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          routes: {
            settingsRouteName: (context) =>
                SettingsView(controller: settingsController),
            newDocRouteName: (context) => const EditDocView(),
          },
          home: BlocProvider(
            create: (context) => AuthBloc(FirebaseAuthProvider()),
            child: const HomeBuilder(),
          ),
        );
      },
    );
  }
}

class HomeBuilder extends StatelessWidget {
  const HomeBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return const Home();
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Cargando...',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const HomeDrawer();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

// class AppRoot extends StatelessWidget {
//   const AppRoot({super.key});

//   @override
//   Widget build(BuildContext context) {
//     devtools.log('AppRoot');
//     final user = AuthService.firebase().currentUser;
//     if (user == null) {
//       return const WelcomeView();
//     } else if (user.isEmailVerified) {
//       return const HomeDrawer();
//     } else {
//       return const VerifyEmailView();
//     }
//   }
// }


/* REMOVED FROM MATERIAL APP FOR LATER USE WHEN I LEARN ABOUT LOCALIZATIONS AND DEEPLINKS
//Localizations
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [
  Locale('en', ''), // English, no country code
],
onGenerateTitle: (BuildContext context) =>
    AppLocalizations.of(context)!.appTitle,

//Deep links
onGenerateRoute: (RouteSettings routeSettings) {
  devtools.log('onGenerateRoute ${routeSettings.name}');
  return MaterialPageRoute<void>(
    settings: routeSettings,
    builder: (BuildContext context) {
      devtools.log('builder ${routeSettings.name}');
      switch (routeSettings.name) {
        case settingsRouteName:
          return SettingsView(controller: settingsController);
        default:
          return const AppRoot();
      }
    },
  );
},
*/