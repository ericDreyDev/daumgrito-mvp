import '../models/service_request.dart';
import 'api_client.dart';

class ServiceRequestService {
  const ServiceRequestService(this._apiClient);

  final ApiClient _apiClient;

  Future<ServiceRequest> create(ServiceRequestInput input) async {
    final data = await _apiClient.post('/service-requests', input.toJson()) as Map<String, dynamic>;
    return ServiceRequest.fromJson(data);
  }

  Future<List<ServiceRequest>> listMine() async {
    final data = await _apiClient.get('/service-requests') as List<dynamic>;
    return data.map((item) => ServiceRequest.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<ServiceRequest> getById(String id) async {
    final data = await _apiClient.get('/service-requests/$id') as Map<String, dynamic>;
    return ServiceRequest.fromJson(data);
  }

  Future<ServiceRequest> updateStatus(String id, String status) async {
    final data = await _apiClient.put('/service-requests/$id/status', {'status': status}) as Map<String, dynamic>;
    return ServiceRequest.fromJson(data);
  }
}
