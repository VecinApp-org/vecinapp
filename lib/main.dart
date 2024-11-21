import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vecinapp/services/auth/firebase_auth_provider.dart';
import 'package:vecinapp/services/geocoding/opencage_geocoding_provider.dart';
import 'package:vecinapp/views/vecinapp.dart';
import 'services/settings/settings_controller.dart';
import 'package:vecinapp/services/cloud/firebase_cloud_provider.dart';
import 'package:vecinapp/services/storage/firebase_storage_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Load user settings
  final settingsController = SettingsController();
  await settingsController.loadSettings();

  // Initialize Auth
  final authProvider = FirebaseAuthProvider();
  await authProvider.initialize();

  // Initialize Cloud database
  final cloudProvider = FirebaseCloudProvider();
  await cloudProvider.initialize(authProvider: authProvider);

  // Initialize Storage
  final storageProvider = FirebaseStorageProvider();

  // Initialize Geocoding
  final geocodingProvider = OpenCageGeocodingProvider();

  // Run app
  runApp(VecinApp(
    settingsController: settingsController,
    authProvider: authProvider,
    cloudProvider: cloudProvider,
    storageProvider: storageProvider,
    geocodingProvider: geocodingProvider,
  ));
}
