import 'package:get/get.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/usecases/patient_usecases.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';

class PatientController extends GetxController {
  final GetPatientProfileUseCase getProfileUseCase;
  final GetAppointmentHistoryUseCase getAppointmentsUseCase;

  PatientController({
    required this.getProfileUseCase,
    required this.getAppointmentsUseCase,
  });

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _patientProfile = Rxn<PatientEntity>();
  PatientEntity? get profile => _patientProfile.value;

  final _appointments = <AppointmentEntity>[].obs;
  List<AppointmentEntity> get appointments => _appointments;

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
}
