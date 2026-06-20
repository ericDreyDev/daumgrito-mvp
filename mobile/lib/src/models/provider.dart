class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.document,
    required this.city,
    required this.neighborhood,
    required this.services,
    required this.averageRating,
    required this.documentUrls,
    required this.validationStatus,
    required this.serviceRadiusKm,
    required this.useCurrentLocation,
    required this.isOnline,
    required this.completedServicesCount,
    this.photoUrl,
    this.professionalDescription,
    this.experience,
    this.availability,
    this.averagePrice,
    this.verificationSelfieUrl,
    this.baseAddress,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String document;
  final String city;
  final String neighborhood;
  final List<String> services;
  final double averageRating;
  final List<String> documentUrls;
  final String validationStatus;
  final int serviceRadiusKm;
  final bool useCurrentLocation;
  final bool isOnline;
  final int completedServicesCount;
  final String? photoUrl;
  final String? professionalDescription;
  final String? experience;
  final String? availability;
  final String? averagePrice;
  final String? verificationSelfieUrl;
  final String? baseAddress;

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      document: json['document'] as String? ?? '',
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      services: List<String>.from(json['services'] as List<dynamic>? ?? const []),
      averageRating: double.tryParse(json['averageRating'].toString()) ?? 0,
      documentUrls: List<String>.from(json['documentUrls'] as List<dynamic>? ?? const []),
      validationStatus: json['validationStatus'] as String? ?? 'Pendente',
      serviceRadiusKm: int.tryParse(json['serviceRadiusKm'].toString()) ?? 5,
      useCurrentLocation: json['useCurrentLocation'] as bool? ?? false,
      isOnline: json['isOnline'] as bool? ?? false,
      completedServicesCount: int.tryParse(json['completedServicesCount'].toString()) ?? 0,
      photoUrl: json['photoUrl'] as String?,
      professionalDescription: json['professionalDescription'] as String?,
      experience: json['experience'] as String?,
      availability: json['availability'] as String?,
      averagePrice: json['averagePrice'] as String?,
      verificationSelfieUrl: json['verificationSelfieUrl'] as String?,
      baseAddress: json['baseAddress'] as String?,
    );
  }
}
