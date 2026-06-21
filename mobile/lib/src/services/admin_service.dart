import '../models/provider.dart';
import '../models/user.dart';
import 'api_client.dart';

class ApprovalHistoryItem {
  const ApprovalHistoryItem({
    required this.id,
    required this.providerName,
    required this.adminName,
    required this.status,
    required this.createdAt,
    this.reason,
  });

  final String id;
  final String providerName;
  final String adminName;
  final String status;
  final DateTime createdAt;
  final String? reason;

  factory ApprovalHistoryItem.fromJson(Map<String, dynamic> json) {
    return ApprovalHistoryItem(
      id: json['id'] as String,
      providerName: json['providerName'] as String? ?? 'Prestador',
      adminName: json['adminName'] as String? ?? 'Administrador',
      status: json['status'] as String? ?? '',
      reason: json['reason'] as String?,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class AdminService {
  const AdminService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProviderProfile>> pendingProviders() async {
    final data = await _apiClient.get('/admin/providers/pending') as List;
    return data
        .map((item) => ProviderProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateProviderApproval({
    required String providerId,
    required String status,
    String? reason,
  }) async {
    await _apiClient.patch('/admin/providers/$providerId/approval', {
      'status': status,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
  }

  Future<List<ApprovalHistoryItem>> approvalHistory() async {
    final data =
        await _apiClient.get('/admin/providers/approval-history') as List;
    return data
        .map((item) => ApprovalHistoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<User>> users() async {
    final data = await _apiClient.get('/admin/users') as List;
    return data.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<User> updateUserAccess({
    required String userId,
    bool? isActive,
    bool? isBlocked,
  }) async {
    final data =
        await _apiClient.patch('/admin/users/$userId/access', {
      if (isActive != null) 'isActive': isActive,
      if (isBlocked != null) 'isBlocked': isBlocked,
    }) as Map<String, dynamic>;

    return User.fromJson(data);
  }

  Future<void> resetPassword({
    required String userId,
    required String password,
  }) async {
    await _apiClient.post('/admin/users/$userId/reset-password', {
      'password': password,
    });
  }
}
