import 'package:flutter/material.dart';

const lightPrimaryColor = Color(0xFFDCEDC8);
const primaryColor = Color(0xFF8BC34A);
const darkPrimaryColor = Color(0xFF689F38);
const tertiaryColor = Color(0xFF03A9F4);
const primaryTextColor = Color(0xFF212121);
const secondaryTextColor = Color(0xFF757575);
const dividerColor = Color(0xFFBDBDBD);

ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimaryColor,
      onPrimary: primaryTextColor,
      secondary: primaryColor,
      onSecondary: primaryTextColor,
      tertiary: tertiaryColor,
      error: Colors.red,
      onError: primaryTextColor,
      surface: Colors.white,
      onSurface: primaryTextColor,
    ));

ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: darkPrimaryColor,
      onSecondary: Colors.white,
      tertiary: tertiaryColor,
      onTertiary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: Color(0xFF689F38),
      onSurface: Color.fromARGB(255, 218, 238, 220),
    ));
