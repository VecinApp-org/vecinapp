import 'package:flutter/material.dart';

//Hue reference:
//Red: 0
//Orange: 30
//Yellow: 60
//Green: 120
//Cyan: 180
//Blue: 240
//Purple: 280
//Magenta: 300

//Hue
const double baseHue = 160;

//Saturation
const double primaryHue = baseHue;
const double primarySaturation = 0.9;

const double secondaryHue = baseHue;
const double secondarySaturation = 0.6;

const double tertiaryHue = baseHue;
const double tertiarySaturation = 0.3;

const double errorHue = 0;
const double errorSaturation = 0.75;

const double neutralHue = baseHue;
const double neutralSaturation = 0.1;

const double neutralVariantHue = baseHue;
const double neutralVariantSaturation = 0.05;

//Light Theme
ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      //primary Light
      primary: p40,
      onPrimary: p100,
      primaryContainer: p90,
      onPrimaryContainer: p10,
      primaryFixed: p90,
      primaryFixedDim: p80,
      onPrimaryFixed: p10,
      onPrimaryFixedVariant: p30,
      //secondary Light
      secondary: s40,
      onSecondary: s100,
      secondaryContainer: s90,
      onSecondaryContainer: s10,
      secondaryFixed: s90,
      secondaryFixedDim: s80,
      onSecondaryFixed: s10,
      onSecondaryFixedVariant: s30,
      //tertiary Light
      tertiary: t40,
      onTertiary: t100,
      tertiaryContainer: t90,
      onTertiaryContainer: t10,
      tertiaryFixed: t90,
      tertiaryFixedDim: t80,
      onTertiaryFixed: t10,
      onTertiaryFixedVariant: t30,
      //error
      error: e40,
      onError: e100,
      errorContainer: e90,
      onErrorContainer: e10,
      //surface
      surfaceDim: n87,
      surface: n98,
      surfaceBright: n99,
      surfaceContainerLowest: n100,
      surfaceContainerLow: n96,
      surfaceContainer: n94,
      surfaceContainerHigh: n92,
      surfaceContainerHighest: n90,
      onSurface: n10,
      onSurfaceVariant: nv30,
      outline: nv50,
      outlineVariant: nv80,
      //other
      inverseSurface: n20,
      onInverseSurface: n95,
      inversePrimary: p80,
      shadow: n0,
      scrim: n0,
    ));

//Dark Theme
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    //primary Dark
    primary: p80,
    onPrimary: p20,
    primaryContainer: p30,
    onPrimaryContainer: p90,
    primaryFixed: p90,
    primaryFixedDim: p80,
    onPrimaryFixed: p10,
    onPrimaryFixedVariant: p30,
    //secondary Dark
    secondary: s80,
    onSecondary: s20,
    secondaryContainer: s30,
    onSecondaryContainer: s90,
    secondaryFixed: s90,
    secondaryFixedDim: s80,
    onSecondaryFixed: s10,
    onSecondaryFixedVariant: s30,
    //tertiary Dark
    tertiary: t80,
    onTertiary: t20,
    tertiaryContainer: t30,
    onTertiaryContainer: t90,
    tertiaryFixed: t90,
    tertiaryFixedDim: t80,
    onTertiaryFixed: t10,
    onTertiaryFixedVariant: t30,
    //error
    error: e80,
    onError: e20,
    errorContainer: e30,
    onErrorContainer: e90,
    //surface
    surface: n6,
    surfaceDim: n6,
    surfaceBright: n24,
    surfaceContainerLowest: n4,
    surfaceContainerLow: n10,
    surfaceContainer: n12,
    surfaceContainerHigh: n17,
    surfaceContainerHighest: n22,
    onSurface: n90,
    onSurfaceVariant: nv80,
    outline: nv60,
    outlineVariant: nv30,
    //other
    inverseSurface: n90,
    onInverseSurface: n20,
    inversePrimary: p40,
    shadow: n0,
    scrim: n0,
  ),
);

//Primary Tonal Pallette
final p0 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.0).toColor();
final p10 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.1).toColor();
final p20 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.2).toColor();
final p30 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.3).toColor();
final p40 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.4).toColor();
final p50 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.5).toColor();
final p60 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.6).toColor();
final p70 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.7).toColor();
final p80 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.8).toColor();
final p90 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.9).toColor();
final p95 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.95).toColor();
final p99 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 0.99).toColor();
final p100 =
    const HSLColor.fromAHSL(1, primaryHue, primarySaturation, 1.0).toColor();

//Secondary Tonal Pallette
final s0 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.0)
    .toColor();
final s10 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.1)
    .toColor();
final s20 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.2)
    .toColor();
final s30 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.3)
    .toColor();
final s40 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.4)
    .toColor();
final s50 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.5)
    .toColor();
final s60 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.6)
    .toColor();
final s70 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.7)
    .toColor();
final s80 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.8)
    .toColor();
final s90 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.9)
    .toColor();
final s95 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.95)
    .toColor();
final s99 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 0.99)
    .toColor();
final s100 = const HSLColor.fromAHSL(1, secondaryHue, secondarySaturation, 1.0)
    .toColor();

//Tertiary Tonal Pallette
final t0 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.0).toColor();
final t10 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.1).toColor();
final t20 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.2).toColor();
final t30 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.3).toColor();
final t40 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.4).toColor();
final t50 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.5).toColor();
final t60 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.6).toColor();
final t70 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.7).toColor();
final t80 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.8).toColor();
final t90 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.9).toColor();
final t95 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.95).toColor();
final t99 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 0.99).toColor();
final t100 =
    const HSLColor.fromAHSL(1, tertiaryHue, tertiarySaturation, 1.0).toColor();

//Error Tonal Pallette
final e0 = const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.0).toColor();
final e10 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.1).toColor();
final e20 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.2).toColor();
final e30 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.3).toColor();
final e40 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.4).toColor();
final e50 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.5).toColor();
final e60 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.6).toColor();
final e70 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.7).toColor();
final e80 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.8).toColor();
final e90 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.9).toColor();
final e95 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.95).toColor();
final e99 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 0.99).toColor();
final e100 =
    const HSLColor.fromAHSL(1, errorHue, errorSaturation, 1.0).toColor();

//Neutral Tonal Pallette
final n0 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.0).toColor();
final n4 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.04).toColor();
final n6 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.06).toColor();
final n10 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.1).toColor();
final n12 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.12).toColor();
final n17 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.17).toColor();
final n20 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.2).toColor();
final n22 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.22).toColor();
final n24 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.24).toColor();
final n30 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.3).toColor();
final n40 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.4).toColor();
final n50 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.5).toColor();
final n60 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.6).toColor();
final n70 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.7).toColor();
final n80 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.8).toColor();
final n87 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.87).toColor();
final n90 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.9).toColor();
final n92 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.92).toColor();
final n94 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.94).toColor();
final n95 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.95).toColor();
final n96 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.96).toColor();
final n98 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.98).toColor();
final n99 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 0.99).toColor();
final n100 =
    const HSLColor.fromAHSL(1, neutralHue, neutralSaturation, 1.0).toColor();

//Neutral Variant Tonal Pallette
final nv0 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.0)
        .toColor();
final nv10 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.1)
        .toColor();
final nv20 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.2)
        .toColor();
final nv30 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.3)
        .toColor();
final nv40 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.4)
        .toColor();
final nv50 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.5)
        .toColor();
final nv60 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.6)
        .toColor();
final nv70 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.7)
        .toColor();
final nv80 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.8)
        .toColor();
final nv90 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 0.9)
        .toColor();
final nv95 = const HSLColor.fromAHSL(
        1, neutralVariantHue, neutralVariantSaturation, 0.95)
    .toColor();
final nv99 = const HSLColor.fromAHSL(
        1, neutralVariantHue, neutralVariantSaturation, 0.99)
    .toColor();
final nv100 =
    const HSLColor.fromAHSL(1, neutralVariantHue, neutralVariantSaturation, 1.0)
        .toColor();
