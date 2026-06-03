class AppConstants {
  static const String appName = 'Hospital Booking Management System';
  
  // Supabase Configuration
  static const String supabaseUrl = 'https://krobgpobgyocuysfmepy.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // To be replaced with actual key
  
  // Roles
  static const String roleSuperAdmin = 'super_admin';
  static const String roleHospitalAdmin = 'hospital_admin';
  static const String roleDoctor = 'doctor';
  static const String rolePatient = 'patient';
  
  // API Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
