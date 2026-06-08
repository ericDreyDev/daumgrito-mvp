enum UserType { client, provider }

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.neighborhood,
    required this.userType,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String neighborhood;
  final UserType userType;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      userType: json['userType'] == 'provider' ? UserType.provider : UserType.client,
    );
  }
}
