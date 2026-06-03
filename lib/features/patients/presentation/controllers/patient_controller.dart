import 'package:get/get.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/usecases/patient_usecases.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';

class PatientController extends GetxController {
  final GetPatientProfileUseCase getProfileUseCase;
  final GetAppointmentHistoryUseCase getAppointmentsUseCase;
  final SearchDoctorsUseCase searchDoctorsUseCase;
  final BookAppointmentUseCase bookAppointmentUseCase;
  final CancelAppointmentUseCase cancelAppointmentUseCase;

  PatientController({
    required this.getProfileUseCase,
    required this.getAppointmentsUseCase,
    required this.searchDoctorsUseCase,
    required this.bookAppointmentUseCase,
    required this.cancelAppointmentUseCase,
  });

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _patientProfile = Rxn<PatientEntity>();
  PatientEntity? get profile => _patientProfile.value;

  final _appointments = <AppointmentEntity>[].obs;
  List<AppointmentEntity> get appointments => _appointments;

  List<AppointmentEntity> get upcomingEvents => _appointments
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
      _patientProfile.value = await getProfileUseCase.execute(userId);
      _appointments.value = await getAppointmentsUseCase.execute(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch patient data: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      _isLoading.value = true;
      await cancelAppointmentUseCase.execute(appointmentId);
      await fetchData(); // Refresh
      Get.snackbar('Success', 'Appointment cancelled');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }
}
