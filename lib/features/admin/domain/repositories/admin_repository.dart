import '../entities/admin_entities.dart';

abstract class AdminRepository {
  Future<AdminStatsEntity> getStats();
  Future<List<AdminUserEntity>> getAllUsers();
  Future<void> updateUserStatus(String userId, bool isActive);
  Future<List<HospitalEntity>> getHospitals();
  Future<void> createHospital(HospitalEntity hospital);
}
