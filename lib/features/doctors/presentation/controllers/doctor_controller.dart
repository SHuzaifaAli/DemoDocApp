import 'package:get/get.dart';
import '../../domain/entities/doctor_profile_entity.dart';
import '../../domain/usecases/doctor_usecases.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';

class DoctorController extends GetxController {
  final GetDoctorProfileUseCase getProfileUseCase;
  final GetDoctorAppointmentsUseCase getAppointmentsUseCase;
  final UpdateAppointmentStatusUseCase updateStatusUseCase;
  final RescheduleAppointmentUseCase rescheduleUseCase;
  final UpdateAvailabilityUseCase updateAvailabilityUseCase;

  DoctorController({
    required this.getProfileUseCase,
    required this.getAppointmentsUseCase,
    required this.updateStatusUseCase,
    required this.rescheduleUseCase,
    required this.updateAvailabilityUseCase,
  });

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _doctorProfile = Rxn<DoctorProfileEntity>();
  DoctorProfileEntity? get profile => _doctorProfile.value;

  final _appointments = <DoctorAppointmentEntity>[].obs;
  List<DoctorAppointmentEntity> get appointments => _appointments;

  List<DoctorAppointmentEntity> get upcomingEvents => _appointments
      .where((a) => a.status == 'confirmed' || a.status == 'pending')
      .where((a) => a.appointmentTime.isAfter(DateTime.now()))
      .toList();

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

  Future<void> reschedule(String appointmentId, DateTime newTime) async {
    try {
      _isLoading.value = true;
      await rescheduleUseCase.execute(appointmentId, newTime);
      await fetchData();
      Get.snackbar('Success', 'Appointment rescheduled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reschedule: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateAvailability(List<Map<String, dynamic>> slots) async {
    final userId = Get.find<AuthController>().user?.id;
    if (userId == null) return;

    try {
      _isLoading.value = true;
      await updateAvailabilityUseCase.execute(userId, slots);
      Get.snackbar('Success', 'Availability updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update availability: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
}
