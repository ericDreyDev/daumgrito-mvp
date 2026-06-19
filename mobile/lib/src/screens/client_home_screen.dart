import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import 'account_screen.dart';
import 'client_requests_screen.dart';
import 'provider_list_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({
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
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      ProviderListScreen(apiClient: widget.apiClient, user: widget.user),
      ClientRequestsScreen(apiClient: widget.apiClient),
      AccountScreen(
        user: widget.user,
        isDarkMode: widget.isDarkMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.search_rounded), label: 'Buscar'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_rounded), label: 'Pedidos'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Conta'),
        ],
      ),
    );
  }
}
