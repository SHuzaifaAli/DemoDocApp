import 'package:get/get.dart';
import 'package:hospital_booking_management/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/doctor_controller.dart';
import '../../domain/usecases/doctor_usecases.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../data/datasources/doctor_remote_datasource.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorRemoteDataSource>(
      () => DoctorRemoteDataSourceImpl(Supabase.instance.client),
    );
    Get.lazyPut<DoctorRepository>(
      () => DoctorRepositoryImpl(Get.find<DoctorRemoteDataSource>()),
    );
    Get.lazyPut(() => GetDoctorProfileUseCase(Get.find<DoctorRepository>()));
    Get.lazyPut(() => GetDoctorAppointmentsUseCase(Get.find<DoctorRepository>()));
    Get.lazyPut(() => UpdateAppointmentStatusUseCase(Get.find<DoctorRepository>()));
    Get.lazyPut(() => AddMedicalRecordUseCase(Get.find<DoctorRepository>()));
    Get.lazyPut(() => RescheduleAppointmentUseCase(Get.find<DoctorRepository>()));

    Get.lazyPut(
      () => DoctorController(
        getProfileUseCase: Get.find<GetDoctorProfileUseCase>(),
        getAppointmentsUseCase: Get.find<GetDoctorAppointmentsUseCase>(),
        updateStatusUseCase: Get.find<UpdateAppointmentStatusUseCase>(),
        rescheduleUseCase: Get.find<RescheduleAppointmentUseCase>(),
      ),
    );
  }
}
