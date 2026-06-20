import 'package:flutter/material.dart';

import '../models/review.dart';
import '../models/service_request.dart';
import '../services/api_client.dart';
import '../services/provider_service.dart';
import '../services/review_service.dart';
import '../services/service_request_service.dart';

class ProviderHistoryScreen extends StatefulWidget {
  const ProviderHistoryScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<ProviderHistoryScreen> createState() => _ProviderHistoryScreenState();
}

class _ProviderHistoryScreenState extends State<ProviderHistoryScreen> {
  late final ServiceRequestService _requestService;
  late final ProviderService _providerService;
  late final ReviewService _reviewService;
  late Future<_HistoryData> _futureData;
  String _categoryFilter = 'Todas';
  String _statusFilter = 'Todos';
  String _ratingFilter = 'Todas';
  DateTime? _fromDate;

  @override
  void initState() {
    super.initState();
    _requestService = ServiceRequestService(widget.apiClient);
    _providerService = ProviderService(widget.apiClient);
    _reviewService = ReviewService(widget.apiClient);
    _futureData = _loadData();
  }

  Future<_HistoryData> _loadData() async {
    final profile = await _providerService.getMyProfile();
    final requests = await _requestService.listMine();
    final reviews = await _reviewService.listProviderReviews(profile.id);
    return _HistoryData(requests: requests, reviews: reviews);
  }

  void _reload() {
    setState(() {
      _futureData = _loadData();
    });
  }

  List<ServiceRequest> _applyFilters(_HistoryData data) {
    return data.requests.where((request) {
      final review = data.reviewFor(request.id);
      final matchesCategory =
          _categoryFilter == 'Todas' || request.service == _categoryFilter;
      final matchesStatus =
          _statusFilter == 'Todos' || request.status == _statusFilter;
      final matchesRating = _ratingFilter == 'Todas' ||
          (review != null && review.rating.toString() == _ratingFilter);
      final matchesDate =
          _fromDate == null || !request.desiredDate.isBefore(_fromDate!);
      return (request.isCompleted || request.isCanceled) &&
          matchesCategory &&
          matchesStatus &&
          matchesRating &&
          matchesDate;
    }).toList();
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
                  child: Text('Histórico de atendimento',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                IconButton.filledTonal(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Atualizar',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Consulte atendimentos finalizados, cancelados ou recusados, com avaliação e valor combinado quando houver.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FutureBuilder<_HistoryData>(
              future: _futureData,
              builder: (context, snapshot) {
                final data = snapshot.data;
                return _HistoryFilters(
                  data: data,
                  categoryFilter: _categoryFilter,
                  statusFilter: _statusFilter,
                  ratingFilter: _ratingFilter,
                  fromDate: _fromDate,
                  onCategoryChanged: (value) =>
                      setState(() => _categoryFilter = value),
                  onStatusChanged: (value) =>
                      setState(() => _statusFilter = value),
                  onRatingChanged: (value) =>
                      setState(() => _ratingFilter = value),
                  onDateChanged: (value) => setState(() => _fromDate = value),
                );
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<_HistoryData>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _HistoryState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Não foi possível carregar',
                    message: 'Confira se a API está rodando e tente novamente.',
                    onAction: _reload,
                  );
                }

                final data = snapshot.data!;
                final history = _applyFilters(data);
                if (history.isEmpty) {
                  return _HistoryState(
                    icon: Icons.history_rounded,
                    title: 'Nenhum atendimento encontrado',
                    message:
                        'Atendimentos finalizados ou cancelados aparecerão aqui.',
                    onAction: _reload,
                  );
                }

                return Column(
                  children: history.map((request) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HistoryCard(
                        request: request,
                        review: data.reviewFor(request.id),
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

class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters({
    required this.data,
    required this.categoryFilter,
    required this.statusFilter,
    required this.ratingFilter,
    required this.fromDate,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onRatingChanged,
    required this.onDateChanged,
  });

  final _HistoryData? data;
  final String categoryFilter;
  final String statusFilter;
  final String ratingFilter;
  final DateTime? fromDate;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onRatingChanged;
  final ValueChanged<DateTime?> onDateChanged;

  @override
  Widget build(BuildContext context) {
    final categories = {
      'Todas',
      ...?data?.requests.map((request) => request.service),
    }.toList();
    final statuses = {
      'Todos',
      ...?data?.requests.map((request) => request.status),
    }.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: categoryFilter,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: categories
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onCategoryChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: statusFilter,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: statuses
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onStatusChanged(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: ratingFilter,
                    decoration: const InputDecoration(labelText: 'Avaliação'),
                    items: ['Todas', '5', '4', '3', '2', '1']
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onRatingChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: fromDate ?? DateTime.now(),
                      );
                      onDateChanged(picked);
                    },
                    icon: const Icon(Icons.event_rounded),
                    label: Text(fromDate == null
                        ? 'Data'
                        : '${fromDate!.day.toString().padLeft(2, '0')}/${fromDate!.month.toString().padLeft(2, '0')}'),
                  ),
                ),
              ],
            ),
            if (fromDate != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => onDateChanged(null),
                  child: const Text('Limpar data'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.request, required this.review});

  final ServiceRequest request;
  final Review? review;

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
                    child: Text(
                        request.clientName.characters.first.toUpperCase())),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.clientName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(request.service),
                    ],
                  ),
                ),
                _StatusPill(status: request.status),
              ],
            ),
            const SizedBox(height: 12),
            _InfoLine(
              icon: Icons.event_rounded,
              label: 'Data do atendimento',
              value: _formatDate(request.desiredDate),
            ),
            _InfoLine(
              icon: Icons.place_rounded,
              label: 'Região',
              value: request.locationNeighborhood,
            ),
            _InfoLine(
              icon: Icons.payments_rounded,
              label: 'Valor combinado',
              value: request.provider.averagePrice ?? 'Não informado',
            ),
            _InfoLine(
              icon: Icons.notes_rounded,
              label: 'Detalhes',
              value: request.description,
            ),
            const Divider(height: 24),
            if (review == null)
              const Text('Sem avaliação registrada.')
            else ...[
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < review!.rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFFF7A00),
                      size: 18,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text('${review!.rating}/5'),
                ],
              ),
              const SizedBox(height: 6),
              Text(review!.comment.isEmpty
                  ? 'Cliente não deixou comentário.'
                  : review!.comment),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
    );
  }
}

class _HistoryState extends StatelessWidget {
  const _HistoryState({
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

class _HistoryData {
  const _HistoryData({required this.requests, required this.reviews});

  final List<ServiceRequest> requests;
  final List<Review> reviews;

  Review? reviewFor(String serviceRequestId) {
    for (final review in reviews) {
      if (review.serviceRequestId == serviceRequestId) return review;
    }
    return null;
  }
}
