import 'package:get/get.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/usecases/admin_usecases.dart';

class AdminController extends GetxController {
  final GetAdminStatsUseCase getStatsUseCase;
  final GetAllUsersUseCase getUsersUseCase;
  final GetHospitalsUseCase getHospitalsUseCase;
  final UpdateUserStatusUseCase updateUserStatusUseCase;
  final CreateHospitalUseCase createHospitalUseCase;
  final GetDepartmentsUseCase getDepartmentsUseCase;
  final CreateDepartmentUseCase createDepartmentUseCase;

  AdminController({
    required this.getStatsUseCase,
    required this.getUsersUseCase,
    required this.getHospitalsUseCase,
    required this.updateUserStatusUseCase,
    required this.createHospitalUseCase,
    required this.getDepartmentsUseCase,
    required this.createDepartmentUseCase,
  });

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _stats = Rxn<AdminStatsEntity>();
  AdminStatsEntity? get stats => _stats.value;

  final _users = <AdminUserEntity>[].obs;
  List<AdminUserEntity> get users => _users;

  final _hospitals = <HospitalEntity>[].obs;
  List<HospitalEntity> get hospitals => _hospitals;

  final _departments = <DepartmentEntity>[].obs;
  List<DepartmentEntity> get departments => _departments;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      _isLoading.value = true;
      _stats.value = await getStatsUseCase.execute();
      _users.value = await getUsersUseCase.execute();
      _hospitals.value = await getHospitalsUseCase.execute();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch admin data: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await updateUserStatusUseCase.execute(userId, isActive);
      // Update local state
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final user = _users[index];
        _users[index] = AdminUserEntity(
          id: user.id,
          fullName: user.fullName,
          email: user.email,
          role: user.role,
          isActive: isActive,
        );
      }
      Get.snackbar('Success', 'User status updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user status: ${e.toString()}');
    }
  }

  Future<void> createHospital(HospitalEntity hospital) async {
    try {
      _isLoading.value = true;
      await createHospitalUseCase.execute(hospital);
      await fetchData(); // Refresh list
      Get.snackbar('Success', 'Hospital created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create hospital: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchDepartments(String hospitalId) async {
    try {
      _isLoading.value = true;
      final result = await getDepartmentsUseCase.execute(hospitalId);
      _departments.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch departments: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createDepartment(DepartmentEntity department) async {
    try {
      _isLoading.value = true;
      await createDepartmentUseCase.execute(department);
      await fetchDepartments(department.hospitalId);
      Get.snackbar('Success', 'Department created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create department: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
}
