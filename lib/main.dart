import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/bindings/auth_binding.dart';
import 'features/patients/presentation/screens/patient_dashboard_screen.dart';
import 'features/patients/presentation/bindings/patient_binding.dart';
import 'features/doctors/presentation/screens/doctor_dashboard_screen.dart';
import 'features/doctors/presentation/bindings/doctor_binding.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/admin/presentation/bindings/admin_binding.dart';
import 'features/payments/presentation/screens/payment_screen.dart';
import 'features/payments/presentation/bindings/payment_binding.dart';
import 'features/video_consultation/presentation/screens/video_call_screen.dart';
import 'features/video_consultation/presentation/bindings/video_call_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await GetStorage.init();
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => RegisterScreen(),
          binding: AuthBinding(),
        ),
        // Placeholders for other routes
        GetPage(
          name: '/patient-dashboard',
          page: () => const PatientDashboardScreen(),
          binding: PatientBinding(),
        ),
        GetPage(
          name: '/doctor-dashboard',
          page: () => const DoctorDashboardScreen(),
          binding: DoctorBinding(),
        ),
        GetPage(
          name: '/admin-dashboard',
          page: () => const AdminDashboardScreen(),
          binding: AdminBinding(),
        ),
        GetPage(
          name: '/payment',
          page: () => const PaymentScreen(),
          binding: PaymentBinding(),
        ),
        GetPage(
          name: '/video-call',
          page: () => const VideoCallScreen(),
          binding: VideoCallBinding(),
        ),
      ],
    );
  }
}
