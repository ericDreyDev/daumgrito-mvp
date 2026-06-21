import 'package:flutter/material.dart';

import '../models/service_request.dart';
import '../services/api_client.dart';
import '../services/service_request_service.dart';
import '../widgets/request_status_timeline.dart';
import 'chat_screen.dart';
import 'review_screen.dart';

class ServiceRequestDetailScreen extends StatefulWidget {
  const ServiceRequestDetailScreen({
    required this.apiClient,
    required this.initialRequest,
    super.key,
  });

  final ApiClient apiClient;
  final ServiceRequest initialRequest;

  @override
  State<ServiceRequestDetailScreen> createState() =>
      _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState
    extends State<ServiceRequestDetailScreen> {
  late final ServiceRequestService _service;
  late ServiceRequest _request;

  @override
  void initState() {
    super.initState();
    _service = ServiceRequestService(widget.apiClient);
    _request = widget.initialRequest;
  }

  Future<void> _refresh() async {
    final request = await _service.getById(_request.id);
    if (!mounted) return;
    setState(() => _request = request);
  }

  Future<void> _openReview() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          apiClient: widget.apiClient,
          request: _request,
        ),
      ),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da solicitação')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Text(_request.provider.name.characters.first
                              .toUpperCase()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_request.service,
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              Text(_request.provider.name),
                            ],
                          ),
                        ),
                        _StatusPill(status: _request.status),
                      ],
                    ),
                    const SizedBox(height: 18),
                    RequestStatusTimeline(status: _request.status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Resumo do pedido',
              children: [
                _InfoLine(
                    icon: Icons.notes_rounded,
                    label: 'Descrição',
                    value: _request.description),
                _InfoLine(
                    icon: Icons.event_rounded,
                    label: 'Data desejada',
                    value: _formatDate(_request.desiredDate)),
                _InfoLine(
                    icon: Icons.place_rounded,
                    label: 'Local',
                    value: _request.locationNeighborhood),
                _InfoLine(
                    icon: Icons.schedule_rounded,
                    label: 'Criado em',
                    value: _formatDate(_request.createdAt)),
              ],
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Profissional',
              children: [
                _InfoLine(
                    icon: Icons.person_rounded,
                    label: 'Nome',
                    value: _request.provider.name),
                _InfoLine(
                    icon: Icons.phone_rounded,
                    label: 'Telefone',
                    value: _request.provider.phone.isEmpty
                        ? 'Não informado'
                        : _request.provider.phone),
                _InfoLine(
                    icon: Icons.payments_rounded,
                    label: 'Valor médio',
                    value: _request.provider.averagePrice ?? 'A combinar'),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(provider: _request.provider)),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Abrir chat demonstrativo'),
            ),
            const SizedBox(height: 10),
            if (!_request.isCompleted && !_request.isCanceled)
              const Text(
                'O prestador atualiza o andamento do atendimento. Quando ele finalizar, a avaliação será liberada.',
              ),
            if (_request.canBeReviewed) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _openReview,
                icon: const Icon(Icons.star_rounded),
                label: const Text('Avaliar profissional'),
              ),
            ],
            if (_request.isCompleted && _request.reviewed) ...[
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      const Expanded(
                          child: Text(
                              'Avaliação enviada. Obrigado por ajudar outros clientes.')),
                    ],
                  ),
                ),
              ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

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
            ...children,
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
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
