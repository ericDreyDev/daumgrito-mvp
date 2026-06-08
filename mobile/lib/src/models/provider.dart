class ProviderProfile {
  const ProviderProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.neighborhood,
    required this.services,
    required this.averageRating,
    this.photoUrl,
    this.professionalDescription,
    this.availability,
    this.averagePrice,
  });

  final String id;
  final String name;
  final String phone;
  final String city;
  final String neighborhood;
  final List<String> services;
  final double averageRating;
  final String? photoUrl;
  final String? professionalDescription;
  final String? availability;
  final String? averagePrice;

  factory ProviderProfile.fromJson(Map<String, dynamic> json) {
    return ProviderProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      services: List<String>.from(json['services'] as List<dynamic>),
      averageRating: (json['averageRating'] as num).toDouble(),
      photoUrl: json['photoUrl'] as String?,
      professionalDescription: json['professionalDescription'] as String?,
      availability: json['availability'] as String?,
      averagePrice: json['averagePrice'] as String?,
    );
  }
}
