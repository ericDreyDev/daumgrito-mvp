import 'package:flutter/material.dart';

import '../models/provider.dart';
import '../models/service_category.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/provider_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/provider_card.dart';
import '../widgets/service_category_chip.dart';
import 'provider_detail_screen.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({
    required this.apiClient,
    required this.user,
    super.key,
  });

  final ApiClient apiClient;
  final User user;

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  late final ProviderService _providerService;
  late Future<List<ProviderProfile>> _futureProviders;
  String? _selectedService;
  DateTime? _desiredDate;
  double _minRating = 0;
  double? _maxAveragePrice;
  bool _bestRating = false;

  @override
  void initState() {
    super.initState();
    _providerService = ProviderService(widget.apiClient);
    _futureProviders = _loadProviders();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<List<ProviderProfile>> _loadProviders() async {
    final providers = await _providerService.listProviders(
      name: _nameController.text.trim(),
      service: _selectedService,
      city: _cityController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      minRating: _minRating,
      bestRating: _bestRating,
    );

    return providers.where(_matchesLocalFilters).toList();
  }

  bool _matchesLocalFilters(ProviderProfile provider) {
    final maxPrice = _maxAveragePrice;
    if (maxPrice != null) {
      final providerPrice = _extractAveragePrice(provider.averagePrice);
      if (providerPrice == null || providerPrice > maxPrice) return false;
    }

    // A data desejada ainda não filtra agenda real no MVP; ela guia a solicitação
    // e fica pronta para a futura camada de disponibilidade/calendário.
    return true;
  }

  double? _extractAveragePrice(String? value) {
    if (value == null) return null;
    final match = RegExp(r'(\d+[,.]?\d*)').firstMatch(value);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  void _search() {
    setState(() => _futureProviders = _loadProviders());
  }

  void _clearFilters() {
    setState(() {
      _nameController.clear();
      _cityController.clear();
      _neighborhoodController.clear();
      _selectedService = null;
      _desiredDate = null;
      _minRating = 0;
      _maxAveragePrice = null;
      _bestRating = false;
      _futureProviders = _loadProviders();
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)),
      initialDate: _desiredDate ?? DateTime.now(),
    );

    if (date != null) {
      setState(() => _desiredDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _search(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLogo(),
                  IconButton.filledTonal(
                    onPressed: _search,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Atualizar',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Qual serviço você quer resolver?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('Escolha como em uma corrida: serviço, região, data e o melhor profissional para você.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              _SearchPanel(
                nameController: _nameController,
                cityController: _cityController,
                neighborhoodController: _neighborhoodController,
                selectedDate: _desiredDate,
                minRating: _minRating,
                maxAveragePrice: _maxAveragePrice,
                bestRating: _bestRating,
                onDateTap: _pickDate,
                onRatingChanged: (value) => setState(() => _minRating = value),
                onPriceChanged: (value) => setState(() => _maxAveragePrice = value),
                onBestRatingChanged: (value) => setState(() => _bestRating = value),
                onSearch: _search,
                onClear: _clearFilters,
              ),
              const SizedBox(height: 18),
              Text('Categoria', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ServiceCategoryChip(
                      category: const ServiceCategory(name: 'Todos', icon: '•'),
                      isSelected: _selectedService == null,
                      onTap: () {
                        setState(() => _selectedService = null);
                        _search();
                      },
                    ),
                    const SizedBox(width: 8),
                    ...serviceCategories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ServiceCategoryChip(
                          category: category,
                          isSelected: _selectedService == category.name,
                          onTap: () {
                            setState(() => _selectedService = category.name);
                            _search();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<ProviderProfile>>(
                future: _futureProviders,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _EmptyState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Não conseguimos carregar agora',
                      description: 'Verifique se a API está rodando e tente novamente.',
                      actionLabel: 'Tentar de novo',
                      onAction: _search,
                    );
                  }

                  final providers = snapshot.data ?? [];
                  if (providers.isEmpty) {
                    return _EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Nenhum profissional encontrado',
                      description: 'Ajuste preço, nota, cidade ou categoria para ampliar as opções.',
                      actionLabel: 'Limpar filtros',
                      onAction: _clearFilters,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${providers.length} opções disponíveis', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      ...providers.map(
                        (provider) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProviderCard(
                            provider: provider,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProviderDetailScreen(
                                    apiClient: widget.apiClient,
                                    provider: provider,
                                    desiredDate: _desiredDate,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.nameController,
    required this.cityController,
    required this.neighborhoodController,
    required this.selectedDate,
    required this.minRating,
    required this.maxAveragePrice,
    required this.bestRating,
    required this.onDateTap,
    required this.onRatingChanged,
    required this.onPriceChanged,
    required this.onBestRatingChanged,
    required this.onSearch,
    required this.onClear,
  });

  final TextEditingController nameController;
  final TextEditingController cityController;
  final TextEditingController neighborhoodController;
  final DateTime? selectedDate;
  final double minRating;
  final double? maxAveragePrice;
  final bool bestRating;
  final VoidCallback onDateTap;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<double?> onPriceChanged;
  final ValueChanged<bool> onBestRatingChanged;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded),
                const SizedBox(width: 8),
                Text('Defina sua busca', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person_search_rounded), labelText: 'Nome do profissional'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city_rounded), labelText: 'Cidade'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: neighborhoodController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.place_rounded), labelText: 'Bairro'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onDateTap,
              child: InputDecorator(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.event_rounded), labelText: 'Data desejada'),
                child: Text(selectedDate == null ? 'Escolher data' : _formatDate(selectedDate!)),
              ),
            ),
            const SizedBox(height: 14),
            Text('Nota mínima: ${minRating == 0 ? 'qualquer' : minRating.toStringAsFixed(1)}'),
            Slider(
              value: minRating,
              min: 0,
              max: 5,
              divisions: 10,
              label: minRating == 0 ? 'Qualquer' : minRating.toStringAsFixed(1),
              onChanged: onRatingChanged,
            ),
            const SizedBox(height: 4),
            Text('Preço médio até'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PriceChoice(label: 'Qualquer', value: null, selectedValue: maxAveragePrice, onSelected: onPriceChanged),
                _PriceChoice(label: 'R\$ 100', value: 100, selectedValue: maxAveragePrice, onSelected: onPriceChanged),
                _PriceChoice(label: 'R\$ 150', value: 150, selectedValue: maxAveragePrice, onSelected: onPriceChanged),
                _PriceChoice(label: 'R\$ 250', value: 250, selectedValue: maxAveragePrice, onSelected: onPriceChanged),
              ],
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: bestRating,
              title: const Text('Ordenar por melhor avaliação'),
              onChanged: onBestRatingChanged,
            ),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: onClear, child: const Text('Limpar'))),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: onSearch,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Buscar profissionais'),
                  ),
                ),
              ],
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

class _PriceChoice extends StatelessWidget {
  const _PriceChoice({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final double? value;
  final double? selectedValue;
  final ValueChanged<double?> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = value == selectedValue;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(value),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
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
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
