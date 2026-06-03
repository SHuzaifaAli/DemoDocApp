import 'package:get/get.dart';
import 'package:hospital_booking_management/features/admin/domain/repositories/admin_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/admin_controller.dart';
import '../../domain/usecases/admin_usecases.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../data/datasources/admin_remote_datasource.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminRemoteDataSource>(
      () => AdminRemoteDataSourceImpl(Supabase.instance.client),
    );
    Get.lazyPut<AdminRepository>(
      () => AdminRepositoryImpl(Get.find<AdminRemoteDataSource>()),
    );
    Get.lazyPut(() => GetAdminStatsUseCase(Get.find<AdminRepository>()));
    Get.lazyPut(() => GetAllUsersUseCase(Get.find<AdminRepository>()));
    Get.lazyPut(() => GetHospitalsUseCase(Get.find<AdminRepository>()));
    Get.lazyPut(() => UpdateUserStatusUseCase(Get.find<AdminRepository>()));
    Get.lazyPut(() => CreateHospitalUseCase(Get.find<AdminRepository>()));

    Get.lazyPut(
      () => AdminController(
        getStatsUseCase: Get.find<GetAdminStatsUseCase>(),
        getUsersUseCase: Get.find<GetAllUsersUseCase>(),
        getHospitalsUseCase: Get.find<GetHospitalsUseCase>(),
        updateUserStatusUseCase: Get.find<UpdateUserStatusUseCase>(),
        createHospitalUseCase: Get.find<CreateHospitalUseCase>(),
      ),
    );
  }
}
