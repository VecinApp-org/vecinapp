import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vecinapp/src/home/home_drawer.dart';
import 'package:vecinapp/src/login/login_view.dart';
import 'package:vecinapp/src/login/verify_email_view.dart';
import 'package:vecinapp/src/login/welcome_view.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

import 'login/register_view.dart';
import 'dart:developer' as devtools show log;

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    devtools.log('build app');
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',

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

          //Theme
          theme: ThemeData(useMaterial3: true),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          //Routes
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  default:
                    return const AppRoot();
                }
              },
            );
          },
          routes: {
            '/homeDrawer': (context) => const HomeDrawer(),
            '/settings': (context) =>
                SettingsView(controller: settingsController),
            '/register': (context) => const RegisterView(),
            '/login': (context) => const LoginView(),
            '/welcome': (context) => const WelcomeView(),
            '/home': (context) => const AppRoot(),
          },
          //Initial route
          home: const AppRoot(),
        );
      },
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: FirebaseAuth.instance.currentUser,
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            if (FirebaseAuth.instance.currentUser == null) {
              devtools.log('AppRoot Active,User null, pushing welcome');
              return const WelcomeView();
            } else if (FirebaseAuth.instance.currentUser!.emailVerified) {
              devtools.log('AppRoot Active, User verified, pushing homeDrawer');
              return const HomeDrawer();
            } else {
              devtools.log(
                  'AppRoot Active, User not verified, pushing verifyEmail');
              return const VerifyEmailView();
            }
          case ConnectionState.waiting:
            devtools.log('AppRoot waiting');
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.none:
            devtools.log('AppRoot none');
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            devtools.log('AppRoot done');
            return const Center(child: CircularProgressIndicator());
          default:
            devtools.log('AppRoot default');
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
