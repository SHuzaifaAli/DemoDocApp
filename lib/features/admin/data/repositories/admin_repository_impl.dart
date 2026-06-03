import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<AdminStatsEntity> getStats() => remoteDataSource.getStats();

  @override
  Future<List<AdminUserEntity>> getAllUsers() => remoteDataSource.getAllUsers();

  @override
  Future<void> updateUserStatus(String userId, bool isActive) =>
      remoteDataSource.updateUserStatus(userId, isActive);

  @override
  Future<List<HospitalEntity>> getHospitals() => remoteDataSource.getHospitals();

  @override
  Future<void> createHospital(HospitalEntity hospital) async {
    // Implementation for creating hospital
  }
}
