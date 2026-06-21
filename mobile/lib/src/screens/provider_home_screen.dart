import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import 'account_screen.dart';
import 'provider_history_screen.dart';
import 'provider_profile_screen.dart';
import 'provider_requests_screen.dart';
import 'provider_schedule_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({
    required this.apiClient,
    required this.user,
    required this.isDarkMode,
    this.onThemeModeChanged,
    this.onLogout,
    super.key,
  });

  final ApiClient apiClient;
  final User user;
  final bool isDarkMode;
  final ValueChanged<bool>? onThemeModeChanged;
  final VoidCallback? onLogout;

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      ProviderRequestsScreen(apiClient: widget.apiClient),
      ProviderHistoryScreen(apiClient: widget.apiClient),
      ProviderScheduleScreen(apiClient: widget.apiClient),
      ProviderProfileScreen(apiClient: widget.apiClient),
      AccountScreen(
        user: widget.user,
        isDarkMode: widget.isDarkMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.assignment_rounded), label: 'Pedidos'),
          NavigationDestination(
              icon: Icon(Icons.history_rounded), label: 'Histórico'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_rounded), label: 'Agenda'),
          NavigationDestination(
              icon: Icon(Icons.badge_rounded), label: 'Perfil'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Conta'),
        ],
      ),
    );
  }
}
