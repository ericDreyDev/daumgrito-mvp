import '../models/provider.dart';
import 'api_client.dart';

class ProviderService {
  const ProviderService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProviderProfile>> listProviders({
    String? service,
    String? city,
    String? neighborhood,
    bool bestRating = false,
  }) async {
    final data = await _apiClient.get('/providers', query: {
      if (service != null && service.isNotEmpty) 'service': service,
      if (city != null && city.isNotEmpty) 'city': city,
      if (neighborhood != null && neighborhood.isNotEmpty) 'neighborhood': neighborhood,
      if (bestRating) 'bestRating': 'true',
    }) as List<dynamic>;

    return data.map((item) => ProviderProfile.fromJson(item as Map<String, dynamic>)).toList();
  }
}
