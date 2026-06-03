import 'package:get/get.dart';
import 'package:hospital_booking_management/features/patients/domain/repositories/patient_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/patient_controller.dart';
import '../../domain/usecases/patient_usecases.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../data/datasources/patient_remote_datasource.dart';

class PatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientRemoteDataSource>(
      () => PatientRemoteDataSourceImpl(Supabase.instance.client),
    );
    Get.lazyPut<PatientRepository>(
      () => PatientRepositoryImpl(Get.find<PatientRemoteDataSource>()),
    );
    Get.lazyPut(() => GetPatientProfileUseCase(Get.find<PatientRepository>()));
    Get.lazyPut(() => GetAppointmentHistoryUseCase(Get.find<PatientRepository>()));
    Get.lazyPut(() => SearchDoctorsUseCase(Get.find<PatientRepository>()));
    Get.lazyPut(() => BookAppointmentUseCase(Get.find<PatientRepository>()));
    Get.lazyPut(() => CancelAppointmentUseCase(Get.find<PatientRepository>()));

    Get.lazyPut(
      () => PatientController(
        getProfileUseCase: Get.find<GetPatientProfileUseCase>(),
        getAppointmentsUseCase: Get.find<GetAppointmentHistoryUseCase>(),
        searchDoctorsUseCase: Get.find<SearchDoctorsUseCase>(),
        bookAppointmentUseCase: Get.find<BookAppointmentUseCase>(),
        cancelAppointmentUseCase: Get.find<CancelAppointmentUseCase>(),
      ),
    );
  }
}
