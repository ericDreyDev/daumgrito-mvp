import 'package:flutter/material.dart';

import '../models/provider.dart';
import '../models/service_request.dart';
import '../services/api_client.dart';
import '../services/service_request_service.dart';
import 'chat_screen.dart';

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({
    required this.apiClient,
    required this.provider,
    this.initialDesiredDate,
    super.key,
  });

  final ApiClient apiClient;
  final ProviderProfile provider;
  final DateTime? initialDesiredDate;

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  DateTime? _desiredDate;
  String? _selectedService;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedService = widget.provider.services.isNotEmpty
        ? widget.provider.services.first
        : null;
    _neighborhoodController.text = widget.provider.neighborhood;
    _desiredDate = widget.initialDesiredDate;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (_desiredDate == null || _selectedService == null) {
      setState(() => _error = 'Escolha o serviço e a data desejada.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ServiceRequestService(widget.apiClient).create(
        ServiceRequestInput(
          providerId: widget.provider.id,
          service: _selectedService!,
          description: _descriptionController.text.trim(),
          desiredDate: _desiredDate!,
          locationNeighborhood: _neighborhoodController.text.trim(),
        ),
      );

      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => _SuccessSheet(
          provider: widget.provider,
          onOpenChat: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) => ChatScreen(provider: widget.provider)),
            );
          },
        ),
      );
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = 'Não foi possível criar a solicitação agora.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar serviço')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: Text(
                          widget.provider.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.provider.name,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 3),
                          Text(widget.provider.averagePrice ??
                              'Valor a combinar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Conte o que você precisa',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedService,
                      decoration: const InputDecoration(
                          labelText: 'Serviço desejado',
                          prefixIcon: Icon(Icons.home_repair_service_rounded)),
                      items: widget.provider.services.map((service) {
                        return DropdownMenuItem(
                            value: service, child: Text(service));
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedService = value),
                      validator: (value) =>
                          value == null ? 'Escolha um serviço.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição do problema',
                        hintText:
                            'Ex.: vazamento na pia da cozinha, preciso de visita pela manhã',
                        prefixIcon: Icon(Icons.notes_rounded),
                      ),
                      minLines: 4,
                      maxLines: 6,
                      validator: (value) =>
                          value == null || value.trim().length < 10
                              ? 'Descreva com mais detalhes.'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(
                          labelText: 'Bairro/local de atendimento',
                          prefixIcon: Icon(Icons.place_rounded)),
                      validator: (value) =>
                          value == null || value.trim().length < 2
                              ? 'Informe o bairro.'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 120)),
                          initialDate: _desiredDate ?? DateTime.now(),
                        );
                        if (date != null) setState(() => _desiredDate = date);
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(_desiredDate == null
                          ? 'Escolher data desejada'
                          : 'Data: ${_formatDate(_desiredDate!)}'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(
                              color: colors.error,
                              fontWeight: FontWeight.w700)),
                    ],
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _submit,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(
                          _isSaving ? 'Enviando...' : 'Enviar solicitação'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet({
    required this.provider,
    required this.onOpenChat,
  });

  final ProviderProfile provider;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 54, color: Color(0xFF0757B8)),
          const SizedBox(height: 12),
          Text(
            'Solicitação enviada',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${provider.name} recebeu seu pedido com status Aguardando aceite. Você já pode iniciar uma conversa demonstrativa.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onOpenChat,
            icon: const Icon(Icons.chat_bubble_rounded),
            label: const Text('Abrir chat'),
          ),
        ],
      ),
    );
  }
}
