import 'package:flutter/material.dart';
import 'vecinapp.dart';
import 'services/settings/settings_controller.dart';
import 'services/settings/settings_service.dart';
import 'dart:developer' as devtools show log;

void main() async {
  devtools.log('main');
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  WidgetsFlutterBinding.ensureInitialized();

  runApp(VecinApp(settingsController: settingsController));
}
