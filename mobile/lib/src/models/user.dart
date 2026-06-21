enum UserType { client, provider, admin }

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.document,
    required this.city,
    required this.neighborhood,
    required this.userType,
    this.isActive = true,
    this.isBlocked = false,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String document;
  final String city;
  final String neighborhood;
  final UserType userType;
  final bool isActive;
  final bool isBlocked;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      document: json['document'] as String? ?? '',
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      userType: switch (json['userType']) {
        'provider' => UserType.provider,
        'admin' => UserType.admin,
        _ => UserType.client,
      },
      isActive: json['isActive'] as bool? ?? true,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? document,
    String? city,
    String? neighborhood,
    UserType? userType,
    bool? isActive,
    bool? isBlocked,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      document: document ?? this.document,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      userType: userType ?? this.userType,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
