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
