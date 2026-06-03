import '../entities/admin_entities.dart';
import '../repositories/admin_repository.dart';

class GetAdminStatsUseCase {
  final AdminRepository repository;
  GetAdminStatsUseCase(this.repository);
  Future<AdminStatsEntity> execute() => repository.getStats();
}

class GetAllUsersUseCase {
  final AdminRepository repository;
  GetAllUsersUseCase(this.repository);
  Future<List<AdminUserEntity>> execute() => repository.getAllUsers();
}

class UpdateUserStatusUseCase {
  final AdminRepository repository;
  UpdateUserStatusUseCase(this.repository);
  Future<void> execute(String userId, bool isActive) => repository.updateUserStatus(userId, isActive);
}

class GetHospitalsUseCase {
  final AdminRepository repository;
  GetHospitalsUseCase(this.repository);
  Future<List<HospitalEntity>> execute() => repository.getHospitals();
}

class CreateHospitalUseCase {
  final AdminRepository repository;
  CreateHospitalUseCase(this.repository);
  Future<void> execute(HospitalEntity hospital) => repository.createHospital(hospital);
}
