import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> signInWithEmail(String email, String password) {
    return remoteDataSource.signIn(email, password);
  }

  @override
  Future<UserEntity> signUpWithEmail(String email, String password, {String? fullName, String? role}) {
    return remoteDataSource.signUp(email, password, fullName: fullName, role: role);
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<String?> getUserRole(String userId) {
    return remoteDataSource.getUserRole(userId);
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) {
    return remoteDataSource.updateProfile(userId, data);
  }
}
