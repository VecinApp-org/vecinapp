import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vecinapp/constants/routes.dart';
import 'package:vecinapp/firebase_options.dart';
import 'package:vecinapp/home/home_drawer.dart';
import 'package:vecinapp/login/login_view.dart';
import 'package:vecinapp/login/verify_email_view.dart';
import 'package:vecinapp/login/welcome_view.dart';
import 'home/settings/settings_controller.dart';
import 'home/settings/settings_view.dart';

import 'login/register_view.dart';
import 'dart:developer' as devtools show log;

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    devtools.log('build MyApp');
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        devtools.log('Firebase: ${snapshot.connectionState}');
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return StreamBuilder(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (context, snapshot) {
                devtools.log('FirebaseAuth: ${snapshot.connectionState}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  case ConnectionState.active:
                    return ListenableBuilder(
                      listenable: settingsController,
                      builder: (BuildContext context, Widget? child) {
                        devtools
                            .log('ThemeMode: ${settingsController.themeMode}');
                        return MaterialApp(
                          debugShowCheckedModeBanner: false,
                          restorationScopeId: 'app',
                          //Theme
                          theme: ThemeData(useMaterial3: true),
                          darkTheme: ThemeData.dark(),
                          themeMode: settingsController.themeMode,
                          routes: {
                            appRootRouteName: (context) => const AppRoot(),
                            welcomeRouteName: (context) => const WelcomeView(),
                            loginRouteName: (context) => const LoginView(),
                            registerRouteName: (context) =>
                                const RegisterView(),
                            verifyEmailRouteName: (context) =>
                                const VerifyEmailView(),
                            homeDrawerRouteName: (context) =>
                                const HomeDrawer(),
                            settingsRouteName: (context) =>
                                SettingsView(controller: settingsController),
                          },
                          home: const AppRoot(),
                          /*
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
                        );
                      },
                    );
                  default:
                    return const CircularProgressIndicator();
                }
              },
            );
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      devtools.log('User null');
      return const WelcomeView();
    } else if (FirebaseAuth.instance.currentUser!.emailVerified) {
      devtools.log('User verified');
      return const HomeDrawer();
    } else {
      devtools.log('User not verified');
      return const VerifyEmailView();
    }
  }
}
