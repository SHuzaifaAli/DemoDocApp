import 'package:get/get.dart';
import '../../domain/entities/doctor_profile_entity.dart';
import '../../domain/usecases/doctor_usecases.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';

class DoctorController extends GetxController {
  final GetDoctorProfileUseCase getProfileUseCase;
  final GetDoctorAppointmentsUseCase getAppointmentsUseCase;
  final UpdateAppointmentStatusUseCase updateStatusUseCase;

  DoctorController({
    required this.getProfileUseCase,
    required this.getAppointmentsUseCase,
    required this.updateStatusUseCase,
  });

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _doctorProfile = Rxn<DoctorProfileEntity>();
  DoctorProfileEntity? get profile => _doctorProfile.value;

  final _appointments = <DoctorAppointmentEntity>[].obs;
  List<DoctorAppointmentEntity> get appointments => _appointments;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    final userId = Get.find<AuthController>().user?.id;
    if (userId == null) return;

    try {
      _isLoading.value = true;
      _doctorProfile.value = await getProfileUseCase.execute(userId);
      _appointments.value = await getAppointmentsUseCase.execute(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch doctor data: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateStatus(String appointmentId, String status) async {
    try {
      await updateStatusUseCase.execute(appointmentId, status);
      await fetchData(); // Refresh data
      Get.snackbar('Success', 'Appointment status updated to $status');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: ${e.toString()}');
    }
  }
}
