import '../models/service_request.dart';
import 'api_client.dart';

class ServiceRequestService {
  const ServiceRequestService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> create(ServiceRequestInput input) async {
    await _apiClient.post('/service-requests', input.toJson());
  }
}
