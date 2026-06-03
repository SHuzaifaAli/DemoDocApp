import 'package:get/get.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/usecases/admin_usecases.dart';

class AdminController extends GetxController {
  final GetAdminStatsUseCase getStatsUseCase;
  final GetAllUsersUseCase getUsersUseCase;
  final GetHospitalsUseCase getHospitalsUseCase;

  AdminController({
    required this.getStatsUseCase,
    required this.getUsersUseCase,
    required this.getHospitalsUseCase,
  });

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _stats = Rxn<AdminStatsEntity>();
  AdminStatsEntity? get stats => _stats.value;

  final _users = <AdminUserEntity>[].obs;
  List<AdminUserEntity> get users => _users;

  final _hospitals = <HospitalEntity>[].obs;
  List<HospitalEntity> get hospitals => _hospitals;

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
}
