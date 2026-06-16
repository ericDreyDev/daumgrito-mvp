import 'package:flutter/material.dart';

import '../models/service_category.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../widgets/app_logo.dart';
import 'client_home_screen.dart';
import 'provider_home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    this.isDarkMode = false,
    this.onThemeModeChanged,
    super.key,
  });

  final bool isDarkMode;
  final ValueChanged<bool>? onThemeModeChanged;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'cliente@demo.local');
  final _phoneController = TextEditingController();
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController(text: 'demo123');
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _photoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _averagePriceController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String _userType = 'client';
  String? _error;
  final Set<String> _selectedServices = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _photoController.dispose();
    _descriptionController.dispose();
    _availabilityController.dispose();
    _averagePriceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isLogin && _userType == 'provider' && _selectedServices.isEmpty) {
      setState(() => _error = 'Escolha pelo menos uma categoria de serviço.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = AuthService(_apiClient);
      final result = _isLogin
          ? await authService.login(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await authService.register({
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'phone': _phoneController.text.trim(),
              'document': _documentController.text.trim(),
              'password': _passwordController.text,
              'city': _cityController.text.trim(),
              'neighborhood': _neighborhoodController.text.trim(),
              'userType': _userType,
            });

      if (!_isLogin && result.user.userType == UserType.provider) {
        await _apiClient.put('/providers/profile', {
          'photoUrl': _photoController.text.trim(),
          'services': _selectedServices.toList(),
          'professionalDescription': _descriptionController.text.trim(),
          'availability': _availabilityController.text.trim(),
          'averagePrice': _averagePriceController.text.trim(),
        });
      }

      if (!mounted) return;
      final nextScreen = result.user.userType == UserType.provider
          ? ProviderHomeScreen(
              apiClient: _apiClient,
              user: result.user,
              isDarkMode: widget.isDarkMode,
              onThemeModeChanged: widget.onThemeModeChanged,
            )
          : ClientHomeScreen(
              apiClient: _apiClient,
              user: result.user,
              isDarkMode: widget.isDarkMode,
              onThemeModeChanged: widget.onThemeModeChanged,
            );

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = 'Não foi possível concluir. Verifique a API e tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
          children: [
            const AppLogo(),
            const SizedBox(height: 22),
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isLogin ? const Color(0xFF12343B) : const Color(0xFF0F766E),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLogin ? 'Entre e peça ajuda em poucos toques.' : 'Crie seu acesso do jeito certo para seu perfil.',
                    style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Use sua conta para buscar profissionais, solicitar serviço e conversar.'
                        : 'Clientes contratam. Prestadores divulgam serviços, preço médio e disponibilidade.',
                    style: const TextStyle(color: Color(0xFFE5F3F1), fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, icon: Icon(Icons.login_rounded), label: Text('Login')),
                          ButtonSegment(value: false, icon: Icon(Icons.person_add_rounded), label: Text('Cadastro')),
                        ],
                        selected: {_isLogin},
                        onSelectionChanged: (value) => setState(() {
                          _isLogin = value.first;
                          _error = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: _isLogin ? _buildLoginFields() : _buildRegisterFields(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: TextStyle(color: colors.error, fontWeight: FontWeight.w800)),
                      ],
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: Text(_isLoading ? 'Aguarde...' : (_isLogin ? 'Entrar' : 'Finalizar cadastro')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFields() {
    return Column(
      key: const ValueKey('login-fields'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_rounded), labelText: 'E-mail'),
          keyboardType: TextInputType.emailAddress,
          validator: _emailValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_rounded), labelText: 'Senha'),
          obscureText: true,
          validator: _passwordValidator,
        ),
        const SizedBox(height: 10),
        Text('Conta demo: cliente@demo.local / demo123', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildRegisterFields() {
    return Column(
      key: const ValueKey('register-fields'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Você quer usar o app como:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ProfileOption(
                title: 'Cliente',
                description: 'Buscar e solicitar serviços',
                icon: Icons.home_repair_service_rounded,
                selected: _userType == 'client',
                onTap: () => setState(() => _userType = 'client'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProfileOption(
                title: 'Prestador',
                description: 'Divulgar meus serviços',
                icon: Icons.handyman_rounded,
                selected: _userType == 'provider',
                onTap: () => setState(() => _userType = 'provider'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome completo'), validator: _requiredText),
        const SizedBox(height: 12),
        TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-mail'), keyboardType: TextInputType.emailAddress, validator: _emailValidator),
        const SizedBox(height: 12),
        TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Telefone'), keyboardType: TextInputType.phone, validator: _requiredText),
        const SizedBox(height: 12),
        TextFormField(controller: _documentController, decoration: const InputDecoration(labelText: 'CPF / CNPJ'), validator: _documentValidator),
        const SizedBox(height: 12),
        TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true, validator: _passwordValidator),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'Cidade'), validator: _requiredText)),
            const SizedBox(width: 10),
            Expanded(child: TextFormField(controller: _neighborhoodController, decoration: const InputDecoration(labelText: 'Bairro'), validator: _requiredText)),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: _userType == 'provider' ? _buildProviderFields() : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildProviderFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: 8),
        Text('Dados profissionais', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextFormField(controller: _photoController, decoration: const InputDecoration(labelText: 'URL da foto de perfil')),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Descrição profissional'),
          minLines: 3,
          maxLines: 5,
          validator: _userType == 'provider' ? _longTextValidator : null,
        ),
        const SizedBox(height: 12),
        TextFormField(controller: _availabilityController, decoration: const InputDecoration(labelText: 'Disponibilidade'), validator: _userType == 'provider' ? _requiredText : null),
        const SizedBox(height: 12),
        TextFormField(controller: _averagePriceController, decoration: const InputDecoration(labelText: 'Valor médio ou a combinar'), validator: _userType == 'provider' ? _requiredText : null),
        const SizedBox(height: 14),
        Text('Categorias de serviço', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
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
    );
  }

  String? _requiredText(String? value) => value == null || value.trim().length < 2 ? 'Informe este campo.' : null;
  String? _longTextValidator(String? value) => value == null || value.trim().length < 10 ? 'Descreva com mais detalhes.' : null;
  String? _documentValidator(String? value) => value == null || value.trim().length < 6 ? 'Informe CPF ou CNPJ.' : null;
  String? _passwordValidator(String? value) => value == null || value.length < 6 ? 'A senha deve ter ao menos 6 caracteres.' : null;
  String? _emailValidator(String? value) => value == null || !value.contains('@') ? 'Informe um e-mail válido.' : null;
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? colors.primary : const Color(0xFFD7DEE8), width: selected ? 1.7 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? colors.primary : const Color(0xFF667085)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(description, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
