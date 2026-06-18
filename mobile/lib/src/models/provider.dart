class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.document,
    required this.city,
    required this.neighborhood,
    required this.services,
    required this.averageRating,
    required this.documents,
    required this.validationStatus,
    required this.serviceRadiusKm,
    required this.useCurrentLocation,
    required this.isOnline,
    required this.completedServicesCount,
    this.photoUrl,
    this.professionalDescription,
    this.experience,
    this.selfieUrl,
    this.baseAddress,
    this.serviceCity,
    this.serviceNeighborhood,
    this.availability,
    this.averagePrice,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String document;
  final String city;
  final String neighborhood;
  final List<String> services;
  final double averageRating;
  final List<String> documents;
  final String validationStatus;
  final int serviceRadiusKm;
  final bool useCurrentLocation;
  final bool isOnline;
  final int completedServicesCount;
  final String? photoUrl;
  final String? professionalDescription;
  final String? experience;
  final String? selfieUrl;
  final String? baseAddress;
  final String? serviceCity;
  final String? serviceNeighborhood;
  final String? availability;
  final String? averagePrice;

  bool get canReceiveRequests => validationStatus == 'Aprovado' && isOnline;

  String get serviceRegion {
    final cityValue = serviceCity?.isNotEmpty == true ? serviceCity! : city;
    final neighborhoodValue = serviceNeighborhood?.isNotEmpty == true
        ? serviceNeighborhood!
        : neighborhood;
    return '$cityValue, $neighborhoodValue • raio de ${serviceRadiusKm}km';
  }

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String,
      document: json['document'] as String? ?? '',
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      services:
          List<String>.from(json['services'] as List<dynamic>? ?? const []),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      documents:
          List<String>.from(json['documents'] as List<dynamic>? ?? const []),
      validationStatus: json['validationStatus'] as String? ?? 'Pendente',
      serviceRadiusKm: (json['serviceRadiusKm'] as num?)?.toInt() ?? 10,
      useCurrentLocation: json['useCurrentLocation'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      completedServicesCount:
          (json['completedServicesCount'] as num?)?.toInt() ?? 0,
      photoUrl: json['photoUrl'] as String?,
      professionalDescription: json['professionalDescription'] as String?,
      experience: json['experience'] as String?,
      selfieUrl: json['selfieUrl'] as String?,
      baseAddress: json['baseAddress'] as String?,
      serviceCity: json['serviceCity'] as String?,
      serviceNeighborhood: json['serviceNeighborhood'] as String?,
      availability: json['availability'] as String?,
      averagePrice: json['averagePrice'] as String?,
    );
  }
}
