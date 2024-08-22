import 'package:flutter/material.dart';
import 'vecinapp.dart';
import 'home/settings/settings_controller.dart';
import 'home/settings/settings_service.dart';
import 'dart:developer' as devtools show log;

void main() async {
  devtools.log('main');
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  WidgetsFlutterBinding.ensureInitialized();

  runApp(VecinApp(settingsController: settingsController));
}
