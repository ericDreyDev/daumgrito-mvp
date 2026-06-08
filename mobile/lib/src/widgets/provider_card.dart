import 'package:flutter/material.dart';

import '../models/provider.dart';

class ProviderCard extends StatelessWidget {
  const ProviderCard({
    required this.provider,
    required this.onRequest,
    super.key,
  });

  final ProviderProfile provider;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(provider.name.characters.first)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name, style: Theme.of(context).textTheme.titleMedium),
                      Text('${provider.city}, ${provider.neighborhood}'),
                    ],
                  ),
                ),
                Text(provider.averageRating == 0 ? 'Novo' : provider.averageRating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.services.map((service) => Chip(label: Text(service))).toList(),
            ),
            const SizedBox(height: 12),
            Text(provider.availability ?? 'Disponibilidade a combinar'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onRequest,
                child: const Text('Solicitar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
