import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user.dart';
import 'screens/admin_home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/provider_home_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

class DaumgritoApp extends StatefulWidget {
  const DaumgritoApp({super.key});

  @override
  State<DaumgritoApp> createState() => _DaumgritoAppState();
}

class _DaumgritoAppState extends State<DaumgritoApp> {
  static const _tokenKey = 'auth_token';

  final _apiClient = ApiClient();
  bool _isDarkMode = false;
  bool _isLoadingSession = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      setState(() => _isLoadingSession = false);
      return;
    }

    try {
      _apiClient.setToken(token);
      final user = await AuthService(_apiClient).currentUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoadingSession = false;
      });
    } catch (_) {
      await prefs.remove(_tokenKey);
      _apiClient.clearToken();
      if (!mounted) return;
      setState(() => _isLoadingSession = false);
    }
  }

  Future<void> _handleAuthenticated(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _apiClient.clearToken();
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dá um grito!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isLoadingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _user;
    if (user == null) {
      return AuthScreen(
        apiClient: _apiClient,
        isDarkMode: _isDarkMode,
        onThemeModeChanged: (value) => setState(() => _isDarkMode = value),
        onAuthenticated: _handleAuthenticated,
      );
    }

    return switch (user.userType) {
      UserType.admin => AdminHomeScreen(
          apiClient: _apiClient,
          user: user,
          isDarkMode: _isDarkMode,
          onThemeModeChanged: (value) => setState(() => _isDarkMode = value),
          onLogout: _logout,
        ),
      UserType.provider => ProviderHomeScreen(
          apiClient: _apiClient,
          user: user,
          isDarkMode: _isDarkMode,
          onThemeModeChanged: (value) => setState(() => _isDarkMode = value),
          onLogout: _logout,
        ),
      UserType.client => ClientHomeScreen(
          apiClient: _apiClient,
          user: user,
          isDarkMode: _isDarkMode,
          onThemeModeChanged: (value) => setState(() => _isDarkMode = value),
          onLogout: _logout,
        ),
    };
  }
}
