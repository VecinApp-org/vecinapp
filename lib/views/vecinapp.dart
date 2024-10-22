import 'package:flutter/material.dart';
import 'package:vecinapp/services/cloud/firebase_cloud_provider.dart';
import 'package:vecinapp/services/settings/settings_controller.dart';
import 'package:vecinapp/services/storage/firebase_storage_provider.dart';
import 'package:vecinapp/views/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/auth/firebase_auth_provider.dart';
import 'package:vecinapp/services/settings/theme_constants.dart';

class VecinApp extends StatelessWidget {
  const VecinApp({super.key, required this.settingsController});
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(
        authProvider: FirebaseAuthProvider(),
        cloudProvider: FirebaseCloudProvider(),
        storageProvider: FirebaseStorageProvider(),
      )..add(const AppEventInitialize()),
      child: ListenableBuilder(
          listenable: settingsController,
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              restorationScopeId: 'vecinapp',
              //Theme
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: settingsController.themeMode,
              home: const AppBlocRouter(),
            );
          }),
    );
  }
}

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