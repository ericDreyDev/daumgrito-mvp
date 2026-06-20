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
    required this.clientName,
    required this.clientPhone,
    required this.clientCity,
    required this.clientNeighborhood,
    required this.reviewed,
    this.reviewRating,
    this.reviewComment,
    this.paymentAmount,
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
  final String clientName;
  final String clientPhone;
  final String clientCity;
  final String clientNeighborhood;
  final bool reviewed;
  final int? reviewRating;
  final String? reviewComment;
  final double? paymentAmount;

  bool get isCompleted {
    final normalized = _normalizeStatus(status);
    return normalized == 'concluido' || normalized == 'finalizado';
  }

  bool get isFinalStatus {
    final normalized = _normalizeStatus(status);
    return isCompleted || normalized == 'cancelado' || normalized == 'recusado';
  }

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
      reviewRating: int.tryParse(json['review_rating'].toString()),
      reviewComment: json['review_comment'] as String?,
      paymentAmount: double.tryParse(json['payment_amount'].toString()),
      clientName: json['client_name'] as String? ?? 'Cliente',
      clientPhone: json['client_phone'] as String? ?? '',
      clientCity: json['client_city'] as String? ?? '',
      clientNeighborhood: json['client_neighborhood'] as String? ?? '',
      provider: ProviderProfile(
        id: json['provider_id'] as String,
        name: json['provider_name'] as String? ?? 'Profissional',
        phone: json['provider_phone'] as String? ?? '',
        email: '',
        document: '',
        city: json['provider_city'] as String? ?? '',
        neighborhood: json['provider_neighborhood'] as String? ?? '',
        services: List<String>.from(json['provider_services'] as List<dynamic>? ?? const []),
        averageRating: double.tryParse(json['provider_average_rating'].toString()) ?? 0,
        documentUrls: const [],
        validationStatus: json['provider_validation_status'] as String? ?? 'Pendente',
        serviceRadiusKm: 5,
        useCurrentLocation: false,
        isOnline: json['provider_is_online'] as bool? ?? false,
        completedServicesCount: 0,
        photoUrl: json['provider_photo_url'] as String?,
        professionalDescription: json['provider_professional_description'] as String?,
        availability: json['provider_availability'] as String?,
        averagePrice: json['provider_average_price'] as String?,
      ),
    );
  }

  static String _normalizeStatus(String value) {
    return value
        .toLowerCase()
        .replaceAll('í', 'i')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ã', 'a')
        .replaceAll('õ', 'o')
        .replaceAll('Ã­', 'i')
        .replaceAll('Ãº', 'u')
        .replaceAll('Ã§', 'c')
        .replaceAll('Ã£', 'a')
        .replaceAll('Ãµ', 'o')
        .replaceAll('ÃƒÂ­', 'i')
        .replaceAll('ÃƒÂº', 'u');
  }
}
