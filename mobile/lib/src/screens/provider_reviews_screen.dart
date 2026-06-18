import 'package:flutter/material.dart';

import '../models/review.dart';
import '../services/api_client.dart';
import '../services/provider_service.dart';
import '../services/review_service.dart';

class ProviderReviewsScreen extends StatefulWidget {
  const ProviderReviewsScreen({
    required this.apiClient,
    super.key,
  });

  final ApiClient apiClient;

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  late final ProviderService _providerService;
  late final ReviewService _reviewService;
  late Future<List<Review>> _futureReviews;
  final Map<String, String> _responses = {};

  @override
  void initState() {
    super.initState();
    _providerService = ProviderService(widget.apiClient);
    _reviewService = ReviewService(widget.apiClient);
    _futureReviews = _loadReviews();
  }

  Future<List<Review>> _loadReviews() async {
    final profile = await _providerService.getMyProfile();
    return _reviewService.listProviderReviews(profile.id);
  }

  void _reload() {
    setState(() => _futureReviews = _loadReviews());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('Avaliações',
                        style: Theme.of(context).textTheme.headlineSmall)),
                IconButton.filledTonal(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Atualizar',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
                'Veja comentários dos clientes e deixe uma resposta demonstrativa.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            FutureBuilder<List<Review>>(
              future: _futureReviews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _ReviewState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Não foi possível carregar',
                    message: 'Confira se a API está rodando e tente novamente.',
                    onAction: _reload,
                  );
                }

                final reviews = snapshot.data ?? [];
                if (reviews.isEmpty) {
                  return _ReviewState(
                    icon: Icons.star_border_rounded,
                    title: 'Nenhuma avaliação ainda',
                    message:
                        'Quando clientes avaliarem seus atendimentos, os comentários aparecerão aqui.',
                    onAction: _reload,
                  );
                }

                return Column(
                  children: reviews.map((review) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReviewCard(
                        review: review,
                        response: _responses[review.id],
                        onRespond: (text) =>
                            setState(() => _responses[review.id] = text),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  const _ReviewCard({
    required this.review,
    required this.onRespond,
    this.response,
  });

  final Review review;
  final String? response;
  final ValueChanged<String> onRespond;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                CircleAvatar(
                    child: Text(widget.review.clientName.characters.first
                        .toUpperCase())),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.review.clientName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 18,
                            color: const Color(0xFFFF7A00),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.review.comment.isEmpty
                ? 'Sem comentário.'
                : widget.review.comment),
            if (widget.response != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Sua resposta: ${widget.response}'),
              ),
            ] else ...[
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration:
                    const InputDecoration(labelText: 'Responder avaliação'),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    widget.onRespond(text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Resposta demonstrativa registrada.')),
                    );
                  },
                  child: const Text('Responder'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewState extends StatelessWidget {
  const _ReviewState({
    required this.icon,
    required this.title,
    required this.message,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onAction, child: const Text('Atualizar')),
          ],
        ),
      ),
    );
  }
}
