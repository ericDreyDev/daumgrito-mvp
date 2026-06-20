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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _documentController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _photoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _averagePriceController = TextEditingController();
  final _documentUrlsController = TextEditingController();
  final _selfieController = TextEditingController();
  final _baseAddressController = TextEditingController();

  late final ProviderService _service;
  late Future<ProviderProfile> _futureProfile;
  final Set<String> _selectedServices = {};
  int _serviceRadiusKm = 5;
  bool _useCurrentLocation = false;
  bool _isOnline = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _service = ProviderService(widget.apiClient);
    _futureProfile = _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _photoController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _availabilityController.dispose();
    _averagePriceController.dispose();
    _documentUrlsController.dispose();
    _selfieController.dispose();
    _baseAddressController.dispose();
    super.dispose();
  }

  Future<ProviderProfile> _loadProfile() async {
    final profile = await _service.getMyProfile();
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _documentController.text = profile.document;
    _cityController.text = profile.city;
    _neighborhoodController.text = profile.neighborhood;
    _photoController.text = profile.photoUrl ?? '';
    _descriptionController.text = profile.professionalDescription ?? '';
    _experienceController.text = profile.experience ?? '';
    _availabilityController.text = profile.availability ?? '';
    _averagePriceController.text = profile.averagePrice ?? '';
    _documentUrlsController.text = profile.documentUrls.join('\n');
    _selfieController.text = profile.verificationSelfieUrl ?? '';
    _baseAddressController.text = profile.baseAddress ?? '${profile.city}, ${profile.neighborhood}';
    _selectedServices
      ..clear()
      ..addAll(profile.services);
    _serviceRadiusKm = profile.serviceRadiusKm;
    _useCurrentLocation = profile.useCurrentLocation;
    _isOnline = profile.isOnline;
    return profile;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha pelo menos uma categoria atendida.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.apiClient.put('/users/me', {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'document': _documentController.text.trim(),
        'city': _cityController.text.trim(),
        'neighborhood': _neighborhoodController.text.trim(),
      });

      await _service.saveProfile(
        photoUrl: _photoController.text.trim(),
        services: _selectedServices.toList(),
        professionalDescription: _descriptionController.text.trim(),
        experience: _experienceController.text.trim(),
        availability: _availabilityController.text.trim(),
        averagePrice: _averagePriceController.text.trim(),
        documentUrls: _documentUrlsController.text
            .split('\n')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
        verificationSelfieUrl: _selfieController.text.trim(),
        baseAddress: _baseAddressController.text.trim(),
        serviceRadiusKm: _serviceRadiusKm,
        useCurrentLocation: _useCurrentLocation,
        isOnline: _isOnline,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil do prestador salvo.')),
      );
      setState(() => _futureProfile = _loadProfile());
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
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
            return _LoadError(onRetry: () => setState(() => _futureProfile = _loadProfile()));
          }

          final profile = snapshot.data!;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                Text('Perfil do prestador', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  'Gerencie seus dados profissionais, area atendida e disponibilidade para novos chamados.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _StatusCard(profile: profile, isOnline: _isOnline, onOnlineChanged: (value) => setState(() => _isOnline = value)),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Dados pessoais',
                  icon: Icons.person_rounded,
                  children: [
                    _TextField(controller: _nameController, label: 'Nome completo', validator: _required),
                    _TextField(controller: _emailController, label: 'E-mail', validator: _email),
                    _TextField(controller: _phoneController, label: 'Telefone', validator: _required),
                    _TextField(controller: _documentController, label: 'CPF', validator: _required),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Perfil profissional',
                  icon: Icons.badge_rounded,
                  children: [
                    _TextField(controller: _photoController, label: 'URL da foto de perfil'),
                    _TextField(controller: _descriptionController, label: 'Descricao profissional', minLines: 4, validator: _longText),
                    _TextField(controller: _experienceController, label: 'Experiencia'),
                    _TextField(controller: _availabilityController, label: 'Disponibilidade de horarios', validator: _required),
                    _TextField(controller: _averagePriceController, label: 'Valor medio ou a combinar', validator: _required),
                    const SizedBox(height: 8),
                    Text('Categorias atendidas', style: Theme.of(context).textTheme.titleSmall),
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
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Verificacao',
                  icon: Icons.verified_user_rounded,
                  children: [
                    _TextField(
                      controller: _documentUrlsController,
                      label: 'Documentos enviados',
                      helper: 'Informe um link ou identificador por linha.',
                      minLines: 3,
                    ),
                    _TextField(controller: _selfieController, label: 'URL da selfie de verificacao'),
                    _ReadonlyPill(label: 'Status da validacao', value: profile.validationStatus),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Localizacao e area',
                  icon: Icons.map_rounded,
                  children: [
                    _TextField(controller: _baseAddressController, label: 'Endereco base', validator: _required),
                    _TextField(controller: _cityController, label: 'Cidade', validator: _required),
                    _TextField(controller: _neighborhoodController, label: 'Bairro', validator: _required),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _useCurrentLocation,
                      onChanged: (value) => setState(() => _useCurrentLocation = value),
                      title: const Text('Usar localizacao atual'),
                      subtitle: const Text('Estrutura preparada para integracao futura com GPS.'),
                    ),
                    Text('Raio de atendimento: $_serviceRadiusKm km', style: Theme.of(context).textTheme.titleSmall),
                    Slider(
                      value: _serviceRadiusKm.toDouble(),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: '$_serviceRadiusKm km',
                      onChanged: (value) => setState(() => _serviceRadiusKm = value.round()),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Salvando...' : 'Salvar perfil'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Campo obrigatorio.' : null;

  String? _email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatorio.';
    if (!value.contains('@')) return 'Informe um e-mail valido.';
    return null;
  }

  String? _longText(String? value) {
    if (value == null || value.trim().length < 10) return 'Descreva com pelo menos 10 caracteres.';
    return null;
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.profile, required this.isOnline, required this.onOnlineChanged});

  final ProviderProfile profile;
  final bool isOnline;
  final ValueChanged<bool> onOnlineChanged;

  @override
  Widget build(BuildContext context) {
    final approved = profile.validationStatus == 'Aprovado';
    final colors = Theme.of(context).colorScheme;
    final statusColor = approved ? Colors.green : profile.validationStatus == 'Reprovado' ? Colors.red : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Text(profile.name.characters.first.toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Badge(text: profile.validationStatus, color: statusColor),
                          _Badge(text: isOnline ? 'Online' : 'Offline', color: isOnline ? Colors.green : Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isOnline,
              onChanged: onOnlineChanged,
              title: const Text('Disponivel para receber chamados'),
              subtitle: Text(
                approved
                    ? 'Quando estiver online, seu perfil pode aparecer para clientes.'
                    : 'Seu perfil so aparece para clientes depois da aprovacao.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.helper,
    this.minLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final String? helper;
  final int minLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        minLines: minLines,
        maxLines: minLines == 1 ? 1 : minLines + 2,
        validator: validator,
        decoration: InputDecoration(labelText: label, helperText: helper),
      ),
    );
  }
}

class _ReadonlyPill extends StatelessWidget {
  const _ReadonlyPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
              Text('Nao foi possivel carregar seu perfil', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Tentar de novo')),
            ],
          ),
        ),
      ),
    );
  }
}
