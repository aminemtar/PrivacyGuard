import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_screen.dart';

class PrivacyGuardApp extends StatelessWidget {
  const PrivacyGuardApp({super.key});

  static const Color navy = Color(0xFF071426);
  static const Color blue = Color(0xFF3678F6);
  static const Color cyan = Color(0xFF55D6E8);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: blue,
      brightness: Brightness.dark,
      surface: const Color(0xFF10223A),
    );

    return MaterialApp(
      title: 'Privacy Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: navy,
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF10223A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return Colors.white70;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return blue;
            return Colors.white12;
          }),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
