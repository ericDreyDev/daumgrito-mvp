import 'package:flutter/material.dart';

import '../models/provider.dart';
import '../models/service_category.dart';
import '../services/api_client.dart';
import '../services/provider_service.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _photoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _averagePriceController = TextEditingController();
  late final ProviderService _service;
  late Future<ProviderProfile> _futureProfile;
  final Set<String> _selectedServices = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _service = ProviderService(widget.apiClient);
    _futureProfile = _loadProfile();
  }

  @override
  void dispose() {
    _photoController.dispose();
    _descriptionController.dispose();
    _availabilityController.dispose();
    _averagePriceController.dispose();
    super.dispose();
  }

  Future<ProviderProfile> _loadProfile() async {
    final profile = await _service.getMyProfile();
    _photoController.text = profile.photoUrl ?? '';
    _descriptionController.text = profile.professionalDescription ?? '';
    _availabilityController.text = profile.availability ?? '';
    _averagePriceController.text = profile.averagePrice ?? '';
    _selectedServices
      ..clear()
      ..addAll(profile.services);
    return profile;
  }

  Future<void> _save() async {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha pelo menos uma categoria.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _service.saveProfile(
        photoUrl: _photoController.text.trim(),
        services: _selectedServices.toList(),
        professionalDescription: _descriptionController.text.trim(),
        availability: _availabilityController.text.trim(),
        averagePrice: _averagePriceController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil profissional salvo.')),
      );
      setState(() => _futureProfile = _loadProfile());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<ProviderProfile>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 44, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 12),
                      Text('Não foi possível carregar seu perfil', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => setState(() => _futureProfile = _loadProfile()),
                        child: const Text('Tentar de novo'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Text('Perfil profissional', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text('Mantenha seus serviços, descrição e disponibilidade atualizados para receber pedidos melhores.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _photoController,
                        decoration: const InputDecoration(labelText: 'URL da foto de perfil'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        minLines: 4,
                        maxLines: 6,
                        decoration: const InputDecoration(labelText: 'Descrição profissional'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _availabilityController,
                        decoration: const InputDecoration(labelText: 'Disponibilidade'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _averagePriceController,
                        decoration: const InputDecoration(labelText: 'Valor médio ou a combinar'),
                      ),
                      const SizedBox(height: 16),
                      Text('Categorias', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: serviceCategories.map((category) {
                          final selected = _selectedServices.contains(category.name);
                          return FilterChip(
                            selected: selected,
                            avatar: Icon(category.icon, size: 18),
                            label: Text(category.name),
                            onSelected: (value) => setState(() {
                              if (value) {
                                _selectedServices.add(category.name);
                              } else {
                                _selectedServices.remove(category.name);
                              }
                            }),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(_isSaving ? 'Salvando...' : 'Salvar perfil'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
