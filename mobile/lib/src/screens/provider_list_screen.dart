import 'package:flutter/material.dart';

import '../models/provider.dart';
import '../services/api_client.dart';
import '../services/provider_service.dart';
import '../widgets/provider_card.dart';
import 'service_request_screen.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  late final ProviderService _providerService;
  late Future<List<ProviderProfile>> _futureProviders;

  @override
  void initState() {
    super.initState();
    _providerService = ProviderService(widget.apiClient);
    _futureProviders = _providerService.listProviders(bestRating: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prestadores')),
      body: FutureBuilder<List<ProviderProfile>>(
        future: _futureProviders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar prestadores: ${snapshot.error}'));
          }

          final providers = snapshot.data ?? [];
          if (providers.isEmpty) {
            return const Center(child: Text('Nenhum prestador encontrado.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: providers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final provider = providers[index];
              return ProviderCard(
                provider: provider,
                onRequest: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ServiceRequestScreen(
                        apiClient: widget.apiClient,
                        provider: provider,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
