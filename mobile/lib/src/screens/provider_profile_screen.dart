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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _photoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceController = TextEditingController();
  final _documentsController = TextEditingController();
  final _selfieController = TextEditingController();
  final _baseAddressController = TextEditingController();
  final _serviceCityController = TextEditingController();
  final _serviceNeighborhoodController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _averagePriceController = TextEditingController();
  late final ProviderService _service;
  late Future<ProviderProfile> _futureProfile;
  final Set<String> _selectedServices = {};
  bool _isSaving = false;
  bool _isOnline = false;
  bool _useCurrentLocation = false;
  double _serviceRadiusKm = 10;
  String _validationStatus = 'Pendente';

  @override
  void initState() {
    super.initState();
    _service = ProviderService(widget.apiClient);
    _futureProfile = _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _documentController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _photoController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    _documentsController.dispose();
    _selfieController.dispose();
    _baseAddressController.dispose();
    _serviceCityController.dispose();
    _serviceNeighborhoodController.dispose();
    _availabilityController.dispose();
    _averagePriceController.dispose();
    super.dispose();
  }

  Future<ProviderProfile> _loadProfile() async {
    final profile = await _service.getMyProfile();
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _emailController.text = profile.email;
    _documentController.text = profile.document;
    _cityController.text = profile.city;
    _neighborhoodController.text = profile.neighborhood;
    _photoController.text = profile.photoUrl ?? '';
    _descriptionController.text = profile.professionalDescription ?? '';
    _experienceController.text = profile.experience ?? '';
    _documentsController.text = profile.documents.join(', ');
    _selfieController.text = profile.selfieUrl ?? '';
    _baseAddressController.text = profile.baseAddress ?? '';
    _serviceCityController.text = profile.serviceCity ?? profile.city;
    _serviceNeighborhoodController.text =
        profile.serviceNeighborhood ?? profile.neighborhood;
    _availabilityController.text = profile.availability ?? '';
    _averagePriceController.text = profile.averagePrice ?? '';
    _selectedServices
      ..clear()
      ..addAll(profile.services);
    _isOnline = profile.isOnline;
    _useCurrentLocation = profile.useCurrentLocation;
    _serviceRadiusKm = profile.serviceRadiusKm.toDouble();
    _validationStatus = profile.validationStatus;
    return profile;
  }

  Future<void> _save() async {
    if (_selectedServices.isEmpty) {
      _showMessage('Escolha pelo menos uma categoria.');
      return;
    }

    if (_descriptionController.text.trim().length < 10) {
      _showMessage('Descreva seu trabalho com um pouco mais de detalhe.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _service.saveProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        document: _documentController.text.trim(),
        city: _cityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        photoUrl: _photoController.text.trim(),
        services: _selectedServices.toList(),
        professionalDescription: _descriptionController.text.trim(),
        experience: _experienceController.text.trim(),
        documents: _documents,
        selfieUrl: _selfieController.text.trim(),
        baseAddress: _baseAddressController.text.trim(),
        serviceCity: _serviceCityController.text.trim(),
        serviceNeighborhood: _serviceNeighborhoodController.text.trim(),
        serviceRadiusKm: _serviceRadiusKm.round(),
        useCurrentLocation: _useCurrentLocation,
        isOnline: _isOnline,
        availability: _availabilityController.text.trim(),
        averagePrice: _averagePriceController.text.trim(),
      );
      if (!mounted) return;
      _showMessage('Perfil profissional salvo.');
      setState(() {
        _futureProfile = _loadProfile();
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleOnline(bool value) async {
    setState(() => _isOnline = value);
    try {
      final profile = await _service.setAvailability(value);
      if (!mounted) return;
      setState(() {
        _isOnline = profile.isOnline;
        _validationStatus = profile.validationStatus;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isOnline = !value);
      _showMessage('Não foi possível atualizar sua disponibilidade.');
    }
  }

  List<String> get _documents {
    return _documentsController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
            return _LoadError(onRetry: () {
              setState(() {
                _futureProfile = _loadProfile();
              });
            });
          }

          final profile = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Text('Perfil profissional',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Gerencie seus dados, validação, área de atendimento e disponibilidade.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _ValidationAndAvailabilityCard(
                status: _validationStatus,
                isOnline: _isOnline,
                canReceiveRequests:
                    _validationStatus == 'Aprovado' && _isOnline,
                onChanged: _toggleOnline,
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Dados do prestador',
                children: [
                  _ProfilePhotoPreview(photoUrl: _photoController.text),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nome completo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      helperText:
                          'O e-mail é usado para login e fica bloqueado nesta etapa.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Telefone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _documentController,
                    decoration: const InputDecoration(labelText: 'CPF'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _photoController,
                    decoration: const InputDecoration(
                        labelText: 'URL da foto de perfil'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Atuação profissional',
                children: [
                  TextField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                        labelText: 'Descrição profissional'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _experienceController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Experiência'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _availabilityController,
                    decoration: const InputDecoration(
                        labelText: 'Disponibilidade descritiva'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _averagePriceController,
                    decoration: const InputDecoration(
                        labelText: 'Valor médio ou a combinar'),
                  ),
                  const SizedBox(height: 16),
                  Text('Categorias/funções atendidas',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: serviceCategories.map((category) {
                      final selected =
                          _selectedServices.contains(category.name);
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
                title: 'Localização e área de atendimento',
                children: [
                  TextField(
                    controller: _baseAddressController,
                    decoration:
                        const InputDecoration(labelText: 'Endereço base'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          decoration:
                              const InputDecoration(labelText: 'Cidade'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _neighborhoodController,
                          decoration:
                              const InputDecoration(labelText: 'Bairro'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _serviceCityController,
                          decoration: const InputDecoration(
                              labelText: 'Cidade atendida'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _serviceNeighborhoodController,
                          decoration: const InputDecoration(
                              labelText: 'Bairro/região atendida'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Raio de atendimento: ${_serviceRadiusKm.round()} km'),
                  Slider(
                    value: _serviceRadiusKm,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '${_serviceRadiusKm.round()} km',
                    onChanged: (value) =>
                        setState(() => _serviceRadiusKm = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _useCurrentLocation,
                    onChanged: (value) =>
                        setState(() => _useCurrentLocation = value),
                    title: const Text('Usar localização atual'),
                    subtitle: const Text(
                        'Mantém sua região de atendimento sincronizada quando disponível.'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Documentos e verificação',
                children: [
                  TextField(
                    controller: _documentsController,
                    decoration: const InputDecoration(
                      labelText: 'Documentos enviados',
                      helperText:
                          'Separe por vírgula. Ex.: CNH, Comprovante de endereço',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _selfieController,
                    decoration: const InputDecoration(
                        labelText: 'URL da selfie de verificação'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Status: $_validationStatus',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Aprovação e reprovação são ações administrativas. O prestador não altera esse status.',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Salvando...' : 'Salvar perfil'),
              ),
              const SizedBox(height: 10),
              _PublicProfileSummary(profile: profile),
            ],
          );
        },
      ),
    );
  }
}

class _ValidationAndAvailabilityCard extends StatelessWidget {
  const _ValidationAndAvailabilityCard({
    required this.status,
    required this.isOnline,
    required this.canReceiveRequests,
    required this.onChanged,
  });

  final String status;
  final bool isOnline;
  final bool canReceiveRequests;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Disponibilidade',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Switch(value: isOnline, onChanged: onChanged),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label: isOnline ? 'Online' : 'Offline',
                  color: isOnline ? colors.primary : colors.outline,
                ),
                _StatusChip(label: status, color: _statusColor(status)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              canReceiveRequests
                  ? 'Seu perfil está aprovado e disponível para receber chamados.'
                  : 'Você só aparece para clientes quando estiver aprovado e online.',
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String value) {
    if (value == 'Aprovado') return const Color(0xFF0757B8);
    if (value == 'Reprovado') return const Color(0xFFC81E1E);
    return const Color(0xFFFF7A00);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w900)),
    );
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

class _ProfilePhotoPreview extends StatelessWidget {
  const _ProfilePhotoPreview({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
      child:
          photoUrl.isEmpty ? const Icon(Icons.person_rounded, size: 34) : null,
    );
  }
}

class _PublicProfileSummary extends StatelessWidget {
  const _PublicProfileSummary({required this.profile});

  final ProviderProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prévia do perfil público',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(profile.name,
                style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(profile.professionalDescription ??
                'Descrição profissional em preenchimento.'),
            const SizedBox(height: 8),
            Text('Região: ${profile.serviceRegion}'),
            Text(
                'Avaliação média: ${profile.averageRating == 0 ? 'Novo' : profile.averageRating.toStringAsFixed(1)}'),
            Text('Serviços realizados: ${profile.completedServicesCount}'),
          ],
        ),
      ),
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
              Icon(Icons.cloud_off_rounded,
                  size: 44, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text('Não foi possível carregar seu perfil',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              OutlinedButton(
                  onPressed: onRetry, child: const Text('Tentar de novo')),
            ],
          ),
        ),
      ),
    );
  }
}
