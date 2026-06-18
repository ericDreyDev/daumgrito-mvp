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
                      MaterialPageRoute(
                          builder: (_) => ChatScreen(provider: provider)),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: provider.canReceiveRequests
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
                  label: Text(provider.canReceiveRequests
                      ? 'Solicitar'
                      : 'Indisponível'),
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
                        foregroundImage: provider.photoUrl == null ||
                                provider.photoUrl!.isEmpty
                            ? null
                            : NetworkImage(provider.photoUrl!),
                        child: provider.photoUrl == null ||
                                provider.photoUrl!.isEmpty
                            ? Text(
                                provider.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w900),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider.name,
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 4),
                            Text(provider.serviceRegion),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _Metric(
                          label: 'Avaliação',
                          value: provider.averageRating == 0
                              ? 'Novo'
                              : provider.averageRating.toStringAsFixed(1)),
                      const SizedBox(width: 10),
                      _Metric(
                          label: 'Serviços',
                          value: provider.completedServicesCount.toString()),
                      const SizedBox(width: 10),
                      _Metric(
                          label: 'Valor',
                          value: provider.averagePrice ?? 'A combinar'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Categorias atendidas',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.services
                  .map((service) => Chip(label: Text(service)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Sobre o profissional',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.professionalDescription ??
                    'Perfil profissional em preenchimento.'),
                if (provider.experience?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Text('Experiência',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(provider.experience!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Disponibilidade e região',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoLine(
                    icon: Icons.schedule_rounded,
                    text:
                        provider.availability ?? 'Disponibilidade a combinar'),
                const SizedBox(height: 8),
                _InfoLine(
                    icon: Icons.map_rounded, text: provider.serviceRegion),
                const SizedBox(height: 8),
                _InfoLine(
                  icon: provider.canReceiveRequests
                      ? Icons.verified_rounded
                      : Icons.pending_actions_rounded,
                  text: provider.canReceiveRequests
                      ? 'Cadastro aprovado e online'
                      : 'Prestador indisponível para novas solicitações',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Comentários de clientes',
            child: _ProviderReviewsPreview(
              service: ReviewService(apiClient),
              providerId: provider.id,
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
          color: const Color(0xFFE5F1FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Color(0xFF516070), fontSize: 12)),
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

class _ProviderReviewsPreview extends StatelessWidget {
  const _ProviderReviewsPreview({
    required this.service,
    required this.providerId,
  });

  final ReviewService service;
  final String providerId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: service.listProviderReviews(providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Text('Este profissional ainda não recebeu comentários.');
        }

        return Column(
          children: reviews.take(3).map((review) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReviewPreview(review: review),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ReviewPreview extends StatelessWidget {
  const _ReviewPreview({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(review.clientName,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              const Icon(Icons.star_rounded,
                  size: 16, color: Color(0xFFFF7A00)),
              Text(review.rating.toString()),
            ],
          ),
          const SizedBox(height: 5),
          Text(review.comment.isEmpty
              ? 'Cliente não deixou comentário.'
              : review.comment),
        ],
      ),
    );
  }
}
