import 'package:flutter/material.dart';
import 'package:vecinapp/services/auth/auth_provider.dart';
import 'package:vecinapp/services/cloud/cloud_provider.dart';
import 'package:vecinapp/services/geocoding/geocoding_provider.dart';
import 'package:vecinapp/services/settings/settings_controller.dart';
import 'package:vecinapp/services/storage/storage_provider.dart';
import 'package:vecinapp/src/localization/app_localizations.dart';
import 'package:vecinapp/views/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecinapp/services/bloc/app_bloc.dart';
import 'package:vecinapp/services/bloc/app_event.dart';
import 'package:vecinapp/services/settings/theme_constants.dart';

class VecinApp extends StatelessWidget {
  const VecinApp({
    super.key,
    required this.settingsController,
    required this.authProvider,
    required this.cloudProvider,
    required this.storageProvider,
    required this.geocodingProvider,
  });
  final SettingsController settingsController;
  final AuthProvider authProvider;
  final CloudProvider cloudProvider;
  final StorageProvider storageProvider;
  final GeocodingProvider geocodingProvider;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(
        authProvider: authProvider,
        cloudProvider: cloudProvider,
        storageProvider: storageProvider,
        geocodingProvider: geocodingProvider,
      )..add(const AppEventInitialize()),
      child: ListenableBuilder(
          listenable: settingsController,
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              restorationScopeId: 'vecinapp',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: settingsController.themeMode,
              home: const AppBlocRouter(),
            );
          }),
    );
  }
}
