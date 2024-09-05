import 'package:flutter/material.dart';
import 'vecinapp.dart';
import 'services/settings/settings_controller.dart';
import 'dart:developer' as devtools show log;

void main() async {
  devtools.log('main');

  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController();
  await settingsController.loadSettings();

  runApp(VecinApp(settingsController: settingsController));
}
