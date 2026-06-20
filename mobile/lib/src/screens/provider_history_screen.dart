import 'package:flutter/material.dart';

import '../models/service_category.dart';
import '../models/service_request.dart';
import '../services/api_client.dart';
import '../services/service_request_service.dart';

class ProviderHistoryScreen extends StatefulWidget {
  const ProviderHistoryScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<ProviderHistoryScreen> createState() => _ProviderHistoryScreenState();
}

class _ProviderHistoryScreenState extends State<ProviderHistoryScreen> {
  late final ServiceRequestService _service;
  late Future<List<ServiceRequest>> _futureRequests;
  String? _category;
  String? _status;
  int? _rating;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _service = ServiceRequestService(widget.apiClient);
    _futureRequests = _service.listMine();
  }

  void _reload() {
    setState(() => _futureRequests = _service.listMine());
  }

  List<ServiceRequest> _filtered(List<ServiceRequest> requests) {
    return requests.where((request) {
      if (!request.isFinalStatus) return false;
      if (_category != null && request.service != _category) return false;
      if (_status != null && request.status != _status) return false;
      if (_rating != null && request.reviewRating != _rating) return false;
      if (_dateRange != null) {
        final date = DateTime(request.desiredDate.year, request.desiredDate.month, request.desiredDate.day);
        final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
        final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day);
        if (date.isBefore(start) || date.isAfter(end)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
    );
    if (range != null) setState(() => _dateRange = range);
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
                Expanded(child: Text('Historico', style: Theme.of(context).textTheme.headlineSmall)),
                IconButton.filledTonal(onPressed: _reload, icon: const Icon(Icons.refresh_rounded), tooltip: 'Atualizar'),
              ],
            ),
            const SizedBox(height: 6),
            Text('Atendimentos finalizados, recusados ou cancelados aparecem aqui.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            _Filters(
              category: _category,
              status: _status,
              rating: _rating,
              dateRange: _dateRange,
              onCategoryChanged: (value) => setState(() => _category = value),
              onStatusChanged: (value) => setState(() => _status = value),
              onRatingChanged: (value) => setState(() => _rating = value),
              onPickDate: _pickDateRange,
              onClear: () => setState(() {
                _category = null;
                _status = null;
                _rating = null;
                _dateRange = null;
              }),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<ServiceRequest>>(
              future: _futureRequests,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 64),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _EmptyHistory(onRetry: _reload, message: 'Nao foi possivel carregar o historico.');
                }

                final requests = _filtered(snapshot.data ?? []);
                if (requests.isEmpty) {
                  return _EmptyHistory(onRetry: _reload, message: 'Nenhum atendimento encontrado para os filtros atuais.');
                }

                return Column(
                  children: requests.map((request) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryCard(request: request),
                      )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.category,
    required this.status,
    required this.rating,
    required this.dateRange,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onRatingChanged,
    required this.onPickDate,
    required this.onClear,
  });

  final String? category;
  final String? status;
  final int? rating;
  final DateTimeRange? dateRange;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<int?> onRatingChanged;
  final VoidCallback onPickDate;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: serviceCategories.map((item) => DropdownMenuItem(value: item.name, child: Text(item.name))).toList(),
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(labelText: 'Status final'),
              items: const ['Finalizado', 'Concluído', 'ConcluÃ­do', 'Cancelado', 'Recusado']
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onStatusChanged,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: rating,
              decoration: const InputDecoration(labelText: 'Avaliacao recebida'),
              items: List.generate(5, (index) => 5 - index)
                  .map((item) => DropdownMenuItem(value: item, child: Text('$item estrelas')))
                  .toList(),
              onChanged: onRatingChanged,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickDate,
                    icon: const Icon(Icons.date_range_rounded),
                    label: Text(dateRange == null ? 'Filtrar por data' : _formatRange(dateRange!)),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.outlined(onPressed: onClear, icon: const Icon(Icons.close_rounded), tooltip: 'Limpar filtros'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatRange(DateTimeRange range) {
    String format(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    return '${format(range.start)} - ${format(range.end)}';
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.request});

  final ServiceRequest request;

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
                CircleAvatar(child: Text(request.clientName.characters.first.toUpperCase())),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.clientName, style: Theme.of(context).textTheme.titleMedium),
                      Text(request.service),
                    ],
                  ),
                ),
                _StatusPill(status: request.status),
              ],
            ),
            const SizedBox(height: 12),
            _Info(icon: Icons.event_rounded, text: 'Atendimento em ${_formatDate(request.desiredDate)}'),
            _Info(icon: Icons.place_rounded, text: request.locationNeighborhood),
            _Info(icon: Icons.notes_rounded, text: request.description),
            if (request.paymentAmount != null) _Info(icon: Icons.payments_rounded, text: 'Valor combinado: R\$ ${request.paymentAmount!.toStringAsFixed(2)}'),
            if (request.reviewRating != null) ...[
              const Divider(height: 22),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
                  const SizedBox(width: 6),
                  Text('${request.reviewRating}/5', style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
              if ((request.reviewComment ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(request.reviewComment!),
              ],
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

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
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
      child: Text(status, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onRetry, required this.message});

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 44, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onRetry, child: const Text('Atualizar')),
          ],
        ),
      ),
    );
  }
}
