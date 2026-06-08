import 'package:flutter/material.dart';

import '../models/provider.dart';
import '../models/service_request.dart';
import '../services/api_client.dart';
import '../services/service_request_service.dart';

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({
    required this.apiClient,
    required this.provider,
    super.key,
  });

  final ApiClient apiClient;
  final ProviderProfile provider;

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

  @override
  void dispose() {
    _descriptionController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _desiredDate == null || _selectedService == null) return;

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitação criada.')));
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.provider.name)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.provider.professionalDescription ?? 'Perfil em preenchimento.'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: const InputDecoration(labelText: 'Serviço desejado'),
              items: widget.provider.services.map((service) {
                return DropdownMenuItem(value: service, child: Text(service));
              }).toList(),
              onChanged: (value) => setState(() => _selectedService = value),
              validator: (value) => value == null ? 'Escolha um serviço.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição da necessidade'),
              minLines: 3,
              maxLines: 5,
              validator: (value) => value == null || value.length < 10 ? 'Descreva com mais detalhes.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _neighborhoodController,
              decoration: const InputDecoration(labelText: 'Local/bairro'),
              validator: (value) => value == null || value.length < 2 ? 'Informe o bairro.' : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 120)),
                  initialDate: DateTime.now(),
                );
                if (date != null) setState(() => _desiredDate = date);
              },
              child: Text(_desiredDate == null ? 'Escolher data' : 'Data: ${_desiredDate!.day}/${_desiredDate!.month}/${_desiredDate!.year}'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: Text(_isSaving ? 'Enviando...' : 'Solicitar serviço'),
            ),
          ],
        ),
      ),
    );
  }
}
