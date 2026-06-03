import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_models.dart';

abstract class AdminRemoteDataSource {
  Future<AdminStatsModel> getStats();
  Future<List<AdminUserModel>> getAllUsers();
  Future<void> updateUserStatus(String userId, bool isActive);
  Future<List<HospitalModel>> getHospitals();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabase;
  AdminRemoteDataSourceImpl(this.supabase);

  @override
  Future<AdminStatsModel> getStats() async {
    // In a real app, this might be an RPC call or multiple count queries
    final patientsCount = await supabase.from(\'patients\').count();
    final doctorsCount = await supabase.from(\'doctors\').count();
    final appointmentsCount = await supabase.from(\'appointments\').count();
    
    return AdminStatsModel(
      totalPatients: patientsCount,
      totalDoctors: doctorsCount,
      totalAppointments: appointmentsCount,
      totalRevenue: 0.0, // Placeholder
    );
  }

  @override
  Future<List<AdminUserModel>> getAllUsers() async {
    final response = await supabase
        .from('user_roles')
        .select('*, profiles(*), roles(name)');
    
    return (response as List).map((json) => AdminUserModel.fromJson(json)).toList();
  }

  @override
  Future<void> updateUserStatus(String userId, bool isActive) async {
    // Assuming profiles table has is_active column or similar logic
    // await supabase.from('profiles').update({'is_active': isActive}).eq('id', userId);
  }

  @override
  Future<List<HospitalModel>> getHospitals() async {
    final response = await supabase.from('hospitals').select();
    return (response as List).map((json) => HospitalModel.fromJson(json)).toList();
  }
}
