import 'package:flutter/material.dart';

import '../models/service_request.dart';
import '../services/api_client.dart';
import '../services/service_request_service.dart';
import '../widgets/request_status_timeline.dart';
import 'chat_screen.dart';

class ProviderRequestDetailScreen extends StatefulWidget {
  const ProviderRequestDetailScreen({
    required this.apiClient,
    required this.initialRequest,
    super.key,
  });

  final ApiClient apiClient;
  final ServiceRequest initialRequest;

  @override
  State<ProviderRequestDetailScreen> createState() => _ProviderRequestDetailScreenState();
}

class _ProviderRequestDetailScreenState extends State<ProviderRequestDetailScreen> {
  late final ServiceRequestService _service;
  late ServiceRequest _request;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _service = ServiceRequestService(widget.apiClient);
    _request = widget.initialRequest;
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    try {
      final request = await _service.updateStatus(_request.id, status);
      if (!mounted) return;
      setState(() => _request = request);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedido recebido')),
      body: ListView(
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
                      CircleAvatar(radius: 28, child: Text(_request.clientName.characters.first.toUpperCase())),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_request.clientName, style: Theme.of(context).textTheme.titleLarge),
                            Text(_request.service),
                          ],
                        ),
                      ),
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
            title: 'Detalhes do cliente',
            children: [
              _InfoLine(icon: Icons.phone_rounded, label: 'Telefone', value: _request.clientPhone.isEmpty ? 'Não informado' : _request.clientPhone),
              _InfoLine(icon: Icons.location_city_rounded, label: 'Cidade', value: _request.clientCity),
              _InfoLine(icon: Icons.place_rounded, label: 'Bairro', value: _request.locationNeighborhood),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Solicitação',
            children: [
              _InfoLine(icon: Icons.notes_rounded, label: 'Descrição', value: _request.description),
              _InfoLine(icon: Icons.event_rounded, label: 'Data desejada', value: _formatDate(_request.desiredDate)),
              _InfoLine(icon: Icons.flag_rounded, label: 'Status', value: _request.status),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChatScreen(provider: _request.provider)),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Responder chat demonstrativo'),
          ),
          const SizedBox(height: 10),
          if (_request.status == 'Solicitado') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUpdating ? null : () => _updateStatus('Cancelado'),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Recusar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isUpdating ? null : () => _updateStatus('Agendado'),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Aceitar'),
                  ),
                ),
              ],
            ),
          ],
          if (_request.status == 'Agendado') ...[
            FilledButton.icon(
              onPressed: _isUpdating ? null : () => _updateStatus('Em andamento'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Iniciar atendimento'),
            ),
          ],
          if (_request.status == 'Em andamento') ...[
            FilledButton.icon(
              onPressed: _isUpdating ? null : () => _updateStatus('Concluído'),
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Concluir atendimento'),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

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
  const _InfoLine({required this.icon, required this.label, required this.value});

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
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
