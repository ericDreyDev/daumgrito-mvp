import '../models/provider.dart';
import 'api_client.dart';

class ProviderService {
  const ProviderService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProviderProfile>> listProviders({
    String? name,
    String? service,
    String? city,
    String? neighborhood,
    double? minRating,
    bool bestRating = false,
  }) async {
    final data = await _apiClient.get('/providers', query: {
      if (name != null && name.isNotEmpty) 'name': name,
      if (service != null && service.isNotEmpty) 'service': service,
      if (city != null && city.isNotEmpty) 'city': city,
      if (neighborhood != null && neighborhood.isNotEmpty) 'neighborhood': neighborhood,
      if (minRating != null && minRating > 0) 'minRating': minRating.toStringAsFixed(1),
      if (bestRating) 'bestRating': 'true',
    }) as List<dynamic>;

    return data.map((item) => ProviderProfile.fromJson(item as Map<String, dynamic>)).toList();
  }
}
