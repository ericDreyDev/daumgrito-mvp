import 'provider.dart';

class ServiceRequestInput {
  const ServiceRequestInput({
    required this.providerId,
    required this.service,
    required this.description,
    required this.desiredDate,
    required this.locationNeighborhood,
  });

  final String providerId;
  final String service;
  final String description;
  final DateTime desiredDate;
  final String locationNeighborhood;

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'service': service,
      'description': description,
      'desiredDate': desiredDate.toIso8601String().split('T').first,
      'locationNeighborhood': locationNeighborhood,
    };
  }
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.service,
    required this.description,
    required this.desiredDate,
    required this.locationNeighborhood,
    required this.status,
    required this.createdAt,
    required this.provider,
    required this.reviewed,
  });

  final String id;
  final String clientId;
  final String providerId;
  final String service;
  final String description;
  final DateTime desiredDate;
  final String locationNeighborhood;
  final String status;
  final DateTime createdAt;
  final ProviderProfile provider;
  final bool reviewed;

  bool get isCompleted => status == 'Concluído' || status == 'ConcluÃ­do';
  bool get canBeReviewed => isCompleted && !reviewed;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      providerId: json['provider_id'] as String,
      service: json['service'] as String,
      description: json['description'] as String,
      desiredDate: DateTime.parse(json['desired_date'] as String),
      locationNeighborhood: json['location_neighborhood'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewed: json['reviewed'] as bool? ?? false,
      provider: ProviderProfile(
        id: json['provider_id'] as String,
        name: json['provider_name'] as String? ?? 'Profissional',
        phone: json['provider_phone'] as String? ?? '',
        city: json['provider_city'] as String? ?? '',
        neighborhood: json['provider_neighborhood'] as String? ?? '',
        services: List<String>.from(json['provider_services'] as List<dynamic>? ?? const []),
        averageRating: double.tryParse(json['provider_average_rating'].toString()) ?? 0,
        photoUrl: json['provider_photo_url'] as String?,
        professionalDescription: json['provider_professional_description'] as String?,
        availability: json['provider_availability'] as String?,
        averagePrice: json['provider_average_price'] as String?,
      ),
    );
  }
}
