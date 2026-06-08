import 'package:flutter/material.dart';

import '../services/api_client.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil profissional')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Funcionalidades do prestador'),
            SizedBox(height: 8),
            Text('Próximo passo: editar serviços, disponibilidade, acompanhar solicitações, responder chat e atualizar status.'),
          ],
        ),
      ),
    );
  }
}
