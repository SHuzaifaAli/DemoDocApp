import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.phoneNumber,
    super.avatarUrl,
    super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? role}) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      avatarUrl: json['avatar_url'],
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
    };
  }
}
