import 'package:flutter/material.dart';

import '../models/service_request.dart';
import '../services/api_client.dart';
import '../services/service_request_service.dart';
import '../widgets/request_status_timeline.dart';
import 'service_request_detail_screen.dart';

class ClientRequestsScreen extends StatefulWidget {
  const ClientRequestsScreen({
    required this.apiClient,
    super.key,
  });

  final ApiClient apiClient;

  @override
  State<ClientRequestsScreen> createState() => _ClientRequestsScreenState();
}

class _ClientRequestsScreenState extends State<ClientRequestsScreen> {
  late final ServiceRequestService _service;
  late Future<List<ServiceRequest>> _futureRequests;
  String _filter = 'Abertas';

  @override
  void initState() {
    super.initState();
    _service = ServiceRequestService(widget.apiClient);
    _futureRequests = _service.listMine();
  }

  void _reload() {
    setState(() {
      _futureRequests = _service.listMine();
    });
  }

  List<ServiceRequest> _filterRequests(List<ServiceRequest> requests) {
    if (_filter == 'Abertas') {
      return requests
          .where((request) => !request.isCompleted && !request.isCanceled)
          .toList();
    }
    if (_filter == 'Concluídas') {
      return requests.where((request) => request.isCompleted).toList();
    }
    if (_filter == 'Canceladas') {
      return requests.where((request) => request.isCanceled).toList();
    }
    return requests;
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
                  child: Text(
                    'Minhas solicitações',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
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
              'Acompanhe cada pedido, converse com o profissional e avalie depois da conclusão.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<ServiceRequest>>(
              future: _futureRequests,
              builder: (context, snapshot) {
                final requests = snapshot.data ?? [];
                return _RequestSummary(requests: requests);
              },
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Abertas', 'Todas', 'Concluídas', 'Canceladas']
                    .map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: _filter == filter,
                      label: Text(filter),
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  );
                }).toList(),
              ),
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
                  return _EmptyRequests(
                    icon: Icons.cloud_off_rounded,
                    title: 'Não foi possível carregar',
                    message: 'Confira se a API está rodando e tente novamente.',
                    actionLabel: 'Tentar de novo',
                    onAction: _reload,
                  );
                }

                final requests = _filterRequests(snapshot.data ?? []);
                if (requests.isEmpty) {
                  return _EmptyRequests(
                    icon: Icons.receipt_long_rounded,
                    title: 'Nenhuma solicitação aqui',
                    message:
                        'Quando você solicitar um serviço, ele aparecerá nesta lista.',
                    actionLabel: 'Atualizar',
                    onAction: _reload,
                  );
                }

                return Column(
                  children: requests.map((request) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RequestCard(
                        request: request,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ServiceRequestDetailScreen(
                                apiClient: widget.apiClient,
                                initialRequest: request,
                              ),
                            ),
                          );
                          _reload();
                        },
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

class _RequestSummary extends StatelessWidget {
  const _RequestSummary({required this.requests});

  final List<ServiceRequest> requests;

  @override
  Widget build(BuildContext context) {
    final open = requests
        .where((request) => !request.isCompleted && !request.isCanceled)
        .length;
    final completed = requests.where((request) => request.isCompleted).length;

    return Row(
      children: [
        Expanded(
            child: _SummaryTile(
                label: 'Abertas',
                value: open.toString(),
                icon: Icons.pending_actions_rounded)),
        const SizedBox(width: 10),
        Expanded(
            child: _SummaryTile(
                label: 'Concluídas',
                value: completed.toString(),
                icon: Icons.verified_rounded)),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                Text(label),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onTap,
  });

  final ServiceRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      child: Text(request.provider.name.characters.first
                          .toUpperCase())),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.service,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(request.provider.name),
                      ],
                    ),
                  ),
                  _StatusPill(status: request.status),
                ],
              ),
              const SizedBox(height: 14),
              RequestStatusTimeline(status: request.status, compact: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event_rounded,
                      size: 18, color: Color(0xFF516070)),
                  const SizedBox(width: 6),
                  Text(_formatDate(request.desiredDate)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
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
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
