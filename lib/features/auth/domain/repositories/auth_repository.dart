import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(String email, String password, {String? fullName, String? role});
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<String?> getUserRole(String userId);
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
}
