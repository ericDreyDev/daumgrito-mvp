import '../models/user.dart';
import 'api_client.dart';

class AuthResult {
  const AuthResult({required this.user, required this.token});

  final User user;
  final String token;
}

class AuthService {
  const AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    final token = data['token'] as String;
    _apiClient.setToken(token);

    return AuthResult(
      user: User.fromJson(data['user'] as Map<String, dynamic>),
      token: token,
    );
  }

  Future<AuthResult> register(Map<String, dynamic> payload) async {
    final data = await _apiClient.post('/auth/register', payload)
        as Map<String, dynamic>;
    final token = data['token'] as String;
    _apiClient.setToken(token);

    return AuthResult(
      user: User.fromJson(data['user'] as Map<String, dynamic>),
      token: token,
    );
  }
}
