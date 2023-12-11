import 'package:flutter/material.dart';

const supabaseSwatch = MaterialColor(0xff34b27b, {
  25: Color(0xfffafefd),
  50: Color(0xfff1fef7),
  75: Color(0xffe9fcf2),
  100: Color(0xffddf8ea),
  200: Color(0xffcef2df),
  300: Color(0xffbde5d0),
  400: Color(0xff8ed2af),
  500: Color(0xff34b27b),
  600: Color(0xff3fcf8e),
  700: Color(0xff40bf86),
  800: Color(0xff2b825b),
  900: Color(0xff122b20),
});

const errorColor = Color(0xffd32f2f);
const errorForeground = Color(0xff8c1d18);

final colorScheme = ColorScheme.fromSwatch(
  primarySwatch: supabaseSwatch,
  brightness: Brightness.light,
  backgroundColor: supabaseSwatch.shade50,
);

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: colorScheme,
  appBarTheme: AppBarTheme(backgroundColor: colorScheme.background),
);
