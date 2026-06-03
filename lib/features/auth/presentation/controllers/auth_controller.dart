import 'package:get/get.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import 'package:hospital_booking_management/core/constants/app_constants.dart';

class AuthController extends GetxController {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  AuthController({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.updateProfileUseCase,
  });

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _user = Rxn<UserEntity>();
  UserEntity? get user => _user.value;

  @override
  void onInit() {
    super.onInit();
    // In a real app, we'd check for an existing session here
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading.value = true;
      final userEntity = await signInUseCase.execute(email, password);
      _user.value = userEntity;
      _navigateBasedOnRole(userEntity.role);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      _isLoading.value = true;
      final userEntity = await signUpUseCase.execute(email, password, fullName);
      _user.value = userEntity;
      _navigateBasedOnRole(userEntity.role);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (user == null) return;
    try {
      _isLoading.value = true;
      await updateProfileUseCase.execute(user!.id, data);
      // Update local user state
      _user.value = UserEntity(
        id: user!.id,
        email: user!.email,
        fullName: data['full_name'] ?? user!.fullName,
        phoneNumber: data['phone_number'] ?? user!.phoneNumber,
        avatarUrl: data['avatar_url'] ?? user!.avatarUrl,
        role: user!.role,
      );
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  void _navigateBasedOnRole(String? role) {
    switch (role) {
      case AppConstants.rolePatient:
        Get.offAllNamed('/patient-dashboard');
        break;
      case AppConstants.roleDoctor:
        Get.offAllNamed('/doctor-dashboard');
        break;
      case AppConstants.roleHospitalAdmin:
      case AppConstants.roleSuperAdmin:
        Get.offAllNamed('/admin-dashboard');
        break;
      default:
        Get.offAllNamed('/login');
    }
  }
}
