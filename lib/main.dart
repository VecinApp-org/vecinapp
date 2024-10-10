import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vecinapp/firebase_options.dart';
import 'package:vecinapp/views/app.dart';
import 'services/settings/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController();
  await settingsController.loadSettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(VecinApp(
    settingsController: settingsController,
  ));
}
