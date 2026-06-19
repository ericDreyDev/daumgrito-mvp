import 'package:flutter/material.dart';

import '../models/provider.dart';
import '../models/user.dart';
import '../services/admin_service.dart';
import '../services/api_client.dart';
import 'account_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({
    required this.apiClient,
    required this.user,
    required this.isDarkMode,
    this.onThemeModeChanged,
    this.onLogout,
    super.key,
  });

  final ApiClient apiClient;
  final User user;
  final bool isDarkMode;
  final ValueChanged<bool>? onThemeModeChanged;
  final VoidCallback? onLogout;

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adminService = AdminService(widget.apiClient);
    final screens = [
      _PendingApprovalsTab(adminService: adminService),
      _ApprovalHistoryTab(adminService: adminService),
      _UsersTab(adminService: adminService, currentUser: widget.user),
      AccountScreen(
        user: widget.user,
        isDarkMode: widget.isDarkMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.verified_user_rounded), label: 'Aprovar'),
          NavigationDestination(
              icon: Icon(Icons.history_rounded), label: 'Historico'),
          NavigationDestination(
              icon: Icon(Icons.group_rounded), label: 'Usuarios'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Conta'),
        ],
      ),
    );
  }
}

class _PendingApprovalsTab extends StatefulWidget {
  const _PendingApprovalsTab({required this.adminService});

  final AdminService adminService;

  @override
  State<_PendingApprovalsTab> createState() => _PendingApprovalsTabState();
}

class _PendingApprovalsTabState extends State<_PendingApprovalsTab> {
  late Future<List<ProviderProfile>> _future;
  final Set<String> _hiddenProviderIds = {};
  String? _loadingProviderAction;

  @override
  void initState() {
    super.initState();
    _future = widget.adminService.pendingProviders();
  }

  void _reload() {
    setState(() {
      _hiddenProviderIds.clear();
      _loadingProviderAction = null;
      _future = widget.adminService.pendingProviders();
    });
  }

  Future<void> _decide(ProviderProfile provider, String status) async {
    final reason = await _askReason(status);
    if (!mounted || reason == null) return;

    final action = status == 'Aprovado' ? 'approve' : 'reject';
    setState(() => _loadingProviderAction = '${provider.id}:$action');
    try {
      await Future.delayed(const Duration(seconds: 1));
      await widget.adminService.updateProviderApproval(
        providerId: provider.id,
        status: status,
        reason: reason,
      );
      if (!mounted) return;
      setState(() {
        _hiddenProviderIds.add(provider.id);
        _loadingProviderAction = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${provider.name}: $status')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingProviderAction = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel alterar ${provider.name}.')),
      );
    }
  }

  Future<String?> _askReason(String status) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'Aprovado' ? 'Aprovar prestador' : 'Reprovar prestador'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Observacao opcional'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Confirmar')),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<ProviderProfile>>(
          future: _future,
          builder: (context, snapshot) {
            final providers = (snapshot.data ?? const <ProviderProfile>[])
                .where((provider) => !_hiddenProviderIds.contains(provider.id))
                .toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                Text('Aprovacoes pendentes',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text('Prestadores novos precisam de revisao antes de aparecer para clientes.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (providers.isEmpty)
                  const _EmptyState(message: 'Nenhum perfil pendente agora.')
                else
                  ...providers.map(
                    (provider) => _ProviderApprovalCard(
                      provider: provider,
                      isApproveLoading:
                          _loadingProviderAction == '${provider.id}:approve',
                      isRejectLoading:
                          _loadingProviderAction == '${provider.id}:reject',
                      onApprove: () => _decide(provider, 'Aprovado'),
                      onReject: () => _decide(provider, 'Reprovado'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProviderApprovalCard extends StatelessWidget {
  const _ProviderApprovalCard({
    required this.provider,
    required this.isApproveLoading,
    required this.isRejectLoading,
    required this.onApprove,
    required this.onReject,
  });

  final ProviderProfile provider;
  final bool isApproveLoading;
  final bool isRejectLoading;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(provider.email),
            Text('${provider.city} - ${provider.neighborhood}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  provider.services.map((service) => Chip(label: Text(service))).toList(),
            ),
            if ((provider.professionalDescription ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(provider.professionalDescription!),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isRejectLoading ? null : onReject,
                    icon: isRejectLoading
                        ? const _ButtonSpinner()
                        : const Icon(Icons.close_rounded),
                    label: Text(isRejectLoading ? 'Aguarde...' : 'Reprovar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isApproveLoading ? null : onApprove,
                    icon: isApproveLoading
                        ? const _ButtonSpinner()
                        : const Icon(Icons.check_rounded),
                    label: Text(isApproveLoading ? 'Aguarde...' : 'Aprovar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalHistoryTab extends StatefulWidget {
  const _ApprovalHistoryTab({required this.adminService});

  final AdminService adminService;

  @override
  State<_ApprovalHistoryTab> createState() => _ApprovalHistoryTabState();
}

class _ApprovalHistoryTabState extends State<_ApprovalHistoryTab> {
  late Future<List<ApprovalHistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.adminService.approvalHistory();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<ApprovalHistoryItem>>(
        future: _future,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <ApprovalHistoryItem>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Text('Historico de aprovacao',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (items.isEmpty)
                const _EmptyState(message: 'Nenhuma decisao registrada.')
              else
                ...items.map((item) => Card(
                      child: ListTile(
                        leading: Icon(item.status == 'Aprovado'
                            ? Icons.verified_rounded
                            : Icons.block_rounded),
                        title: Text('${item.providerName} - ${item.status}'),
                        subtitle: Text(
                          '${item.adminName} em ${_formatDate(item.createdAt)}'
                          '${item.reason?.isNotEmpty == true ? '\n${item.reason}' : ''}',
                        ),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _UsersTab extends StatefulWidget {
  const _UsersTab({required this.adminService, required this.currentUser});

  final AdminService adminService;
  final User currentUser;

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  late Future<List<User>> _future;
  final Map<String, User> _userOverrides = {};
  String? _loadingUserAction;

  @override
  void initState() {
    super.initState();
    _future = widget.adminService.users();
  }

  Future<void> _setAccess(User user, {bool? isActive, bool? isBlocked}) async {
    final action = isActive != null ? 'access' : 'block';
    setState(() => _loadingUserAction = '${user.id}:$action');
    try {
      await Future.delayed(const Duration(seconds: 1));
      final updatedUser = await widget.adminService.updateUserAccess(
        userId: user.id,
        isActive: isActive,
        isBlocked: isBlocked,
      );
      if (!mounted) return;
      setState(() {
        _userOverrides[user.id] = updatedUser;
        _loadingUserAction = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingUserAction = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel alterar ${user.name}.')),
      );
    }
  }

  Future<void> _resetPassword(User user) async {
    final controller = TextEditingController(text: '123456');
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redefinir senha de ${user.name}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nova senha'),
          obscureText: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Salvar')),
        ],
      ),
    );
    controller.dispose();
    if (password == null || password.length < 6) return;

    setState(() => _loadingUserAction = '${user.id}:password');
    try {
      await Future.delayed(const Duration(seconds: 1));
      await widget.adminService
          .resetPassword(userId: user.id, password: password);
      if (!mounted) return;
      setState(() => _loadingUserAction = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha redefinida para ${user.name}.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingUserAction = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel redefinir ${user.name}.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<User>>(
        future: _future,
        builder: (context, snapshot) {
          final users = (snapshot.data ?? const <User>[])
              .map((user) => _userOverrides[user.id] ?? user)
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Text('Usuarios', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text('Controle acesso sem editar dados sensiveis do perfil.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (users.isEmpty)
                const _EmptyState(message: 'Nenhum usuario encontrado.')
              else
                ...users.map((user) => _UserAdminCard(
                      user: user,
                      isCurrentUser: user.id == widget.currentUser.id,
                      isPasswordLoading:
                          _loadingUserAction == '${user.id}:password',
                      isAccessLoading:
                          _loadingUserAction == '${user.id}:access',
                      isBlockLoading:
                          _loadingUserAction == '${user.id}:block',
                      onActivate: () => _setAccess(user, isActive: true),
                      onInactivate: () => _setAccess(user, isActive: false),
                      onBlock: () => _setAccess(user, isBlocked: true),
                      onUnblock: () => _setAccess(user, isBlocked: false),
                      onResetPassword: () => _resetPassword(user),
                    )),
            ],
          );
        },
      ),
    );
  }
}

class _UserAdminCard extends StatelessWidget {
  const _UserAdminCard({
    required this.user,
    required this.isCurrentUser,
    required this.isPasswordLoading,
    required this.isAccessLoading,
    required this.isBlockLoading,
    required this.onActivate,
    required this.onInactivate,
    required this.onBlock,
    required this.onUnblock,
    required this.onResetPassword,
  });

  final User user;
  final bool isCurrentUser;
  final bool isPasswordLoading;
  final bool isAccessLoading;
  final bool isBlockLoading;
  final VoidCallback onActivate;
  final VoidCallback onInactivate;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(user.name),
              subtitle: Text('${user.email} - ${_userTypeLabel(user.userType)}'),
              trailing: _AccessBadge(user: user),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: isCurrentUser || isPasswordLoading
                      ? null
                      : onResetPassword,
                  icon: isPasswordLoading
                      ? const _ButtonSpinner()
                      : const Icon(Icons.password_rounded),
                  label: Text(isPasswordLoading ? 'Aguarde...' : 'Senha'),
                ),
                OutlinedButton.icon(
                  onPressed: isCurrentUser || isAccessLoading
                      ? null
                      : (user.isActive ? onInactivate : onActivate),
                  icon: isAccessLoading
                      ? const _ButtonSpinner()
                      : Icon(user.isActive
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded),
                  label: Text(isAccessLoading
                      ? 'Aguarde...'
                      : (user.isActive ? 'Inativar' : 'Ativar')),
                ),
                FilledButton.icon(
                  onPressed: isCurrentUser || isBlockLoading
                      ? null
                      : (user.isBlocked ? onUnblock : onBlock),
                  icon: isBlockLoading
                      ? const _ButtonSpinner()
                      : Icon(user.isBlocked
                          ? Icons.lock_open_rounded
                          : Icons.block_rounded),
                  label: Text(isBlockLoading
                      ? 'Aguarde...'
                      : (user.isBlocked ? 'Desbloquear' : 'Bloquear')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessBadge extends StatelessWidget {
  const _AccessBadge({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final blocked = user.isBlocked || !user.isActive;
    return Chip(
      label: Text(blocked ? 'Restrito' : 'Ativo'),
      avatar: Icon(blocked ? Icons.lock_rounded : Icons.check_circle_rounded),
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String _userTypeLabel(UserType userType) {
  return switch (userType) {
    UserType.admin => 'Admin',
    UserType.provider => 'Prestador',
    UserType.client => 'Cliente',
  };
}
