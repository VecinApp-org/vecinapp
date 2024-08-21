import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vecinapp/firebase_options.dart';

import 'app.dart';
import 'home/settings/settings_controller.dart';
import 'home/settings/settings_service.dart';
import 'dart:developer' as devtools show log;

void main() async {
  devtools.log('main');
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp(settingsController: settingsController));
}
