import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'theme/app_theme.dart';

class DaumgritoApp extends StatefulWidget {
  const DaumgritoApp({super.key});

  @override
  State<DaumgritoApp> createState() => _DaumgritoAppState();
}

class _DaumgritoAppState extends State<DaumgritoApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dá um grito!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthScreen(
        isDarkMode: _isDarkMode,
        onThemeModeChanged: (value) => setState(() => _isDarkMode = value),
      ),
    );
  }
}
