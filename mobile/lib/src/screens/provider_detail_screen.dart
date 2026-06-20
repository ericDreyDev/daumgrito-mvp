import 'package:flutter/material.dart';

import '../models/provider.dart';
import '../models/review.dart';
import '../services/api_client.dart';
import '../services/review_service.dart';
import 'chat_screen.dart';
import 'service_request_screen.dart';

class ProviderDetailScreen extends StatelessWidget {
  const ProviderDetailScreen({
    required this.apiClient,
    required this.provider,
    this.desiredDate,
    super.key,
  });

  final ApiClient apiClient;
  final ProviderProfile provider;
  final DateTime? desiredDate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profissional')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChatScreen(provider: provider)),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: provider.validationStatus == 'Aprovado' && provider.isOnline
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ServiceRequestScreen(
                                apiClient: apiClient,
                                provider: provider,
                                initialDesiredDate: desiredDate,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.assignment_turned_in_rounded),
                  label: const Text('Solicitar'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: colors.primaryContainer,
                        foregroundColor: colors.onPrimaryContainer,
                        child: Text(
                          provider.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider.name, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 4),
                            Text('${provider.city}, ${provider.neighborhood}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _Metric(label: 'Avaliacao', value: provider.averageRating == 0 ? 'Novo' : provider.averageRating.toStringAsFixed(1)),
                      const SizedBox(width: 10),
                      _Metric(label: 'Servicos', value: provider.completedServicesCount.toString()),
                      const SizedBox(width: 10),
                      _Metric(label: 'Valor', value: provider.averagePrice ?? 'A combinar'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Servicos oferecidos',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.services.map((service) => Chip(label: Text(service))).toList(),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Sobre o profissional',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.professionalDescription ?? 'Perfil profissional em preenchimento.'),
                if ((provider.experience ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _InfoLine(icon: Icons.workspace_premium_rounded, text: provider.experience!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Disponibilidade e regiao',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoLine(icon: Icons.schedule_rounded, text: provider.availability ?? 'Disponibilidade a combinar'),
                const SizedBox(height: 8),
                _InfoLine(icon: Icons.map_rounded, text: 'Atende ${provider.city}, ${provider.neighborhood} e raio de ${provider.serviceRadiusKm} km'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Comentarios de clientes',
            child: FutureBuilder<List<Review>>(
              future: ReviewService(apiClient).listProviderReviews(provider.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final reviews = snapshot.data ?? [];
                if (reviews.isEmpty) {
                  return const Text('Este profissional ainda nao recebeu comentarios.');
                }

                return Column(
                  children: reviews.take(5).map((review) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReviewPreview(
                        name: review.clientName,
                        text: review.comment.isEmpty ? 'Sem comentario.' : review.comment,
                        rating: review.rating.toString(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _ReviewPreview extends StatelessWidget {
  const _ReviewPreview({required this.name, required this.text, required this.rating});

  final String name;
  final String text;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800))),
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
              Text(rating),
            ],
          ),
          const SizedBox(height: 5),
          Text(text),
        ],
      ),
    );
  }
}
