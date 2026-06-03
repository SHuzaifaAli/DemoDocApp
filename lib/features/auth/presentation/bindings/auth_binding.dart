import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/auth_controller.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Data sources
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(Supabase.instance.client),
    );

    // Repositories
    Get.lazyPut<AuthRepositoryImpl>(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
    );

    // Use cases
    Get.lazyPut(() => SignInUseCase(Get.find<AuthRepositoryImpl>()));

    // Controllers
    Get.lazyPut(
      () => AuthController(signInUseCase: Get.find<SignInUseCase>()),
    );
  }
}
