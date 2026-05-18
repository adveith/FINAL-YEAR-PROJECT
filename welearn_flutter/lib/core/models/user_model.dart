import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? profilePhoto;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profilePhoto,
    this.isEmailVerified = false,
    this.isActive = true,
    this.createdAt,
  });

  bool get isAuthenticated => id.isNotEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? '',
        phone: json['phone'] as String?,
        profilePhoto: json['profilePhoto'] as String?,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'profilePhoto': profilePhoto,
        'isEmailVerified': isEmailVerified,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String jsonStr) =>
      UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

  UserModel copyWith({
    String? name,
    String? phone,
    String? profilePhoto,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        role: role,
        phone: phone ?? this.phone,
        profilePhoto: profilePhoto ?? this.profilePhoto,
        isEmailVerified: isEmailVerified,
        isActive: isActive,
        createdAt: createdAt,
      );
}

class AuthResponse {
  final String token;
  final String? refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final userJson = data['user'] as Map<String, dynamic>? ??
        json['user'] as Map<String, dynamic>? ??
        data;
    return AuthResponse(
      token: data['token'] as String? ?? json['token'] as String? ?? '',
      refreshToken: data['refreshToken'] as String?,
      user: UserModel.fromJson(userJson),
    );
  }
}
