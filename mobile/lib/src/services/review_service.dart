import 'api_client.dart';

class ReviewService {
  const ReviewService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> create({
    required String providerId,
    required String serviceRequestId,
    required int rating,
    required String comment,
  }) async {
    await _apiClient.post('/reviews', {
      'providerId': providerId,
      'serviceRequestId': serviceRequestId,
      'rating': rating,
      'comment': comment,
    });
  }
}
