class Review {
  const Review({
    required this.id,
    required this.providerId,
    required this.clientId,
    required this.serviceRequestId,
    required this.rating,
    required this.comment,
    required this.clientName,
    required this.createdAt,
  });

  final String id;
  final String providerId;
  final String clientId;
  final String serviceRequestId;
  final int rating;
  final String comment;
  final String clientName;
  final DateTime createdAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      clientId: json['client_id'] as String,
      serviceRequestId: json['service_request_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      clientName: json['client_name'] as String? ?? 'Cliente',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
