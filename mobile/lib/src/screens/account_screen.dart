import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/app_logo.dart';
import 'auth_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    required this.user,
    required this.isDarkMode,
    this.onThemeModeChanged,
    super.key,
  });

  final User user;
  final bool isDarkMode;
  final ValueChanged<bool>? onThemeModeChanged;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _notificationsEnabled = true;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AuthScreen(
          isDarkMode: _isDarkMode,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          const AppLogo(compact: true),
          const SizedBox(height: 18),
          Text('Conta', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
              'Veja seus dados, ajuste preferências e saia da sessão quando precisar.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _ProfileHeader(user: widget.user),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Informações do perfil',
            children: [
              _InfoLine(
                  icon: Icons.person_rounded,
                  label: 'Nome',
                  value: widget.user.name),
              _InfoLine(
                  icon: Icons.mail_rounded,
                  label: 'E-mail',
                  value: widget.user.email),
              _InfoLine(
                  icon: Icons.phone_rounded,
                  label: 'Telefone',
                  value: widget.user.phone),
              _InfoLine(
                  icon: Icons.badge_rounded,
                  label: 'CPF / CNPJ',
                  value: widget.user.document.isEmpty
                      ? 'Não informado'
                      : widget.user.document),
              _InfoLine(
                  icon: Icons.location_city_rounded,
                  label: 'Cidade',
                  value: widget.user.city),
              _InfoLine(
                  icon: Icons.place_rounded,
                  label: 'Bairro',
                  value: widget.user.neighborhood),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Configurações',
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isDarkMode,
                title: const Text('Modo escuro'),
                subtitle: const Text('Alternar aparência do app'),
                secondary: const Icon(Icons.dark_mode_rounded),
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                  widget.onThemeModeChanged?.call(value);
                },
              ),
              const Divider(),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _notificationsEnabled,
                title: const Text('Notificações'),
                subtitle: const Text('Receber avisos sobre solicitações'),
                secondary: const Icon(Icons.notifications_active_rounded),
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline_rounded),
                title: const Text('Privacidade e segurança'),
                subtitle:
                    const Text('Configurações previstas para próximas versões'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showComingSoon('Privacidade e segurança'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Suporte',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text('Central de ajuda'),
                subtitle:
                    const Text('Tire dúvidas sobre pedidos e profissionais'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showComingSoon('Central de ajuda'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Sobre o Dá um grito!'),
                subtitle: const Text('MVP para contratação de serviços locais'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showAbout(),
              ),
            ],
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title será refinado nas próximas etapas.')),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Dá um grito!',
      applicationVersion: 'MVP',
      applicationLegalese: 'Conectando clientes e prestadores locais.',
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              child: Text(
                  user.name.isEmpty
                      ? '?'
                      : user.name.characters.first.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 3),
                  Text(user.userType == UserType.client
                      ? 'Cliente'
                      : 'Prestador'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
