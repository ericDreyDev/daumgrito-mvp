import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'theme/app_theme.dart';

class DaumgritoApp extends StatelessWidget {
  const DaumgritoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dá um grito!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthScreen(),
    );
  }
}
