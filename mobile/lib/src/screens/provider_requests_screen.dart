import 'package:flutter/material.dart';

import '../models/service_request.dart';
import '../services/api_client.dart';
import '../services/service_request_service.dart';
import '../widgets/request_status_timeline.dart';
import 'provider_request_detail_screen.dart';

class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({
    required this.apiClient,
    super.key,
  });

  final ApiClient apiClient;

  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  late final ServiceRequestService _service;
  late Future<List<ServiceRequest>> _futureRequests;
  String _filter = 'Novas';

  @override
  void initState() {
    super.initState();
    _service = ServiceRequestService(widget.apiClient);
    _futureRequests = _service.listMine();
  }

  void _reload() {
    setState(() => _futureRequests = _service.listMine());
  }

  List<ServiceRequest> _filterRequests(List<ServiceRequest> requests) {
    if (_filter == 'Novas') {
      return requests.where((request) => request.status == 'Solicitado' || request.status == 'Aguardando aceite').toList();
    }
    if (_filter == 'Em andamento') {
      return requests.where((request) => request.status == 'Aceito' || request.status == 'Agendado' || request.status == 'Em andamento').toList();
    }
    if (_filter == 'Finalizadas') {
      return requests.where((request) => request.isCompleted).toList();
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
                Expanded(child: Text('Solicitacoes recebidas', style: Theme.of(context).textTheme.headlineSmall)),
                IconButton.filledTonal(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Atualizar',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Aceite, recuse ou acompanhe pedidos enviados por clientes.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Novas', 'Em andamento', 'Finalizadas', 'Todas'].map((filter) {
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
                  return _EmptyProviderRequests(
                    icon: Icons.cloud_off_rounded,
                    title: 'Nao foi possivel carregar',
                    message: 'Confira se a API esta rodando e tente novamente.',
                    onAction: _reload,
                  );
                }

                final requests = _filterRequests(snapshot.data ?? []);
                if (requests.isEmpty) {
                  return _EmptyProviderRequests(
                    icon: Icons.assignment_late_rounded,
                    title: 'Nenhum pedido nesta lista',
                    message: 'Novas solicitacoes aparecerao aqui quando clientes escolherem seu perfil.',
                    onAction: _reload,
                  );
                }

                return Column(
                  children: requests.map((request) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProviderRequestCard(
                        request: request,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProviderRequestDetailScreen(
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

class _ProviderRequestCard extends StatelessWidget {
  const _ProviderRequestCard({
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
                  CircleAvatar(child: Text(request.clientName.characters.first.toUpperCase())),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.service, style: Theme.of(context).textTheme.titleMedium),
                        Text(request.clientName),
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
                  const Icon(Icons.place_rounded, size: 18, color: Color(0xFF667085)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(request.locationNeighborhood)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_available_rounded, size: 18, color: Color(0xFF667085)),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Cliente pediu: ${_formatDate(request.desiredDate)}')),
                  const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFF667085)),
                  const SizedBox(width: 4),
                  Text(_formatDate(request.createdAt)),
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
      child: Text(
        status,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _EmptyProviderRequests extends StatelessWidget {
  const _EmptyProviderRequests({
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
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
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
