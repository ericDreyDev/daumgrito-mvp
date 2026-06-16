import 'package:flutter/material.dart';

import '../services/api_client.dart';

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
  final Set<String> _selectedPeriods = {'Manhã', 'Tarde'};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Text('Agenda e disponibilidade', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('Defina quando você costuma atender. Nesta etapa, a agenda é demonstrativa e ajuda a compor seu perfil.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _ScheduleCard(
            title: 'Dias de atendimento',
            children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'].map((day) {
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
            title: 'Horários preferenciais',
            children: ['Manhã', 'Tarde', 'Noite', 'Plantão'].map((period) {
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
                  Text('Resumo público', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(_summary),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Agenda demonstrativa salva localmente.')),
                      );
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Salvar disponibilidade'),
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
    final periods = _selectedPeriods.isEmpty ? 'horários a combinar' : _selectedPeriods.join(', ');
    return 'Atende em $days, nos períodos: $periods.';
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
