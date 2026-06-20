import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/provider_service.dart';

class ProviderScheduleScreen extends StatefulWidget {
  const ProviderScheduleScreen({
    required this.apiClient,
    super.key,
  });

  final ApiClient apiClient;

  @override
  State<ProviderScheduleScreen> createState() => _ProviderScheduleScreenState();
}

class _ProviderScheduleScreenState extends State<ProviderScheduleScreen> {
  final Set<String> _selectedDays = {'Seg', 'Ter', 'Qua', 'Qui', 'Sex'};
  final Set<String> _selectedPeriods = {'Manha', 'Tarde'};
  late final ProviderService _providerService;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _providerService = ProviderService(widget.apiClient);
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);
    try {
      final profile = await _providerService.getMyProfile();
      await _providerService.saveProfile(
        photoUrl: profile.photoUrl ?? '',
        services: profile.services,
        professionalDescription: profile.professionalDescription ?? 'Perfil profissional em preenchimento.',
        experience: profile.experience ?? '',
        availability: _summary,
        averagePrice: profile.averagePrice ?? 'A combinar',
        documentUrls: profile.documentUrls,
        verificationSelfieUrl: profile.verificationSelfieUrl ?? '',
        baseAddress: profile.baseAddress ?? '${profile.city}, ${profile.neighborhood}',
        serviceRadiusKm: profile.serviceRadiusKm,
        useCurrentLocation: profile.useCurrentLocation,
        isOnline: profile.isOnline,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponibilidade salva no perfil.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Text('Agenda e disponibilidade', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('Defina quando voce costuma atender. Este resumo fica visivel no seu perfil publico.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _ScheduleCard(
            title: 'Dias de atendimento',
            children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'].map((day) {
              return FilterChip(
                selected: _selectedDays.contains(day),
                label: Text(day),
                onSelected: (value) => setState(() {
                  if (value) {
                    _selectedDays.add(day);
                  } else {
                    _selectedDays.remove(day);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _ScheduleCard(
            title: 'Horarios preferenciais',
            children: ['Manha', 'Tarde', 'Noite', 'Plantao'].map((period) {
              return FilterChip(
                selected: _selectedPeriods.contains(period),
                label: Text(period),
                onSelected: (value) => setState(() {
                  if (value) {
                    _selectedPeriods.add(period);
                  } else {
                    _selectedPeriods.remove(period);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumo publico', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(_summary),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveAvailability,
                    icon: const Icon(Icons.save_rounded),
                    label: Text(_isSaving ? 'Salvando...' : 'Salvar disponibilidade'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _summary {
    final days = _selectedDays.isEmpty ? 'dias a combinar' : _selectedDays.join(', ');
    final periods = _selectedPeriods.isEmpty ? 'horarios a combinar' : _selectedPeriods.join(', ');
    return 'Atende em $days, nos periodos: $periods.';
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
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
            Wrap(spacing: 8, runSpacing: 8, children: children),
          ],
        ),
      ),
    );
  }
}
