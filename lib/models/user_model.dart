class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? governce;
  final int? age;
  final String? role;
  final String? qualification;
  final int? experienceYear;
  final String? token;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.governce,
    this.age,
    this.role,
    this.qualification,
    this.experienceYear,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      governce: json['governce'],
      age: json['age'],
      role: json['role'],
      qualification: json['qualification'],
      experienceYear: json['experience_year'],
      token: json['token'],
    );
  }

  factory UserModel.fromApiResponse(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    return UserModel(
      id: userJson?['id'] ?? 0,
      firstName: userJson?['first_name'] ?? '',
      lastName: userJson?['last_name'] ?? '',
      email: userJson?['email'] ?? '',
      phone: userJson?['phone'] ?? '',
      governce: userJson?['governce'],
      age: userJson?['age'],
      role: userJson?['role'],
      qualification: userJson?['qualification'],
      experienceYear: userJson?['experience_year'],
      token: json['token'],
    );
  }

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'governce': governce,
      'age': age,
      'role': role,
    };
  }
}
