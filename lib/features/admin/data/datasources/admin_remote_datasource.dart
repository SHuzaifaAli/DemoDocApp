import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_models.dart';

abstract class AdminRemoteDataSource {
  Future<AdminStatsModel> getStats();
  Future<List<AdminUserModel>> getAllUsers();
  Future<void> updateUserStatus(String userId, bool isActive);
  Future<List<HospitalModel>> getHospitals();
  Future<void> createHospital(HospitalModel hospital);
  Future<List<DepartmentModel>> getDepartments(String hospitalId);
  Future<void> createDepartment(DepartmentModel department);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabase;
  AdminRemoteDataSourceImpl(this.supabase);

  @override
  Future<AdminStatsModel> getStats() async {
    // In a real app, this might be an RPC call or multiple count queries
    final patientsResponse = await supabase.from('patients').select('*').count(CountOption.exact);
    final doctorsResponse = await supabase.from('doctors').select('*').count(CountOption.exact);
    final appointmentsResponse = await supabase.from('appointments').select('*').count(CountOption.exact);
    
    return AdminStatsModel(
      totalPatients: patientsResponse.count ?? 0,
      totalDoctors: doctorsResponse.count ?? 0,
      totalAppointments: appointmentsResponse.count ?? 0,
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

  @override
  Future<void> createHospital(HospitalModel hospital) async {
    await supabase.from('hospitals').insert({
      'name': hospital.name,
      'address': hospital.address,
      'phone_number': hospital.phoneNumber,
    });
  }

  @override
  Future<List<DepartmentModel>> getDepartments(String hospitalId) async {
    final response = await supabase.from('departments').select().eq('hospital_id', hospitalId);
    return (response as List).map((json) => DepartmentModel.fromJson(json)).toList();
  }

  @override
  Future<void> createDepartment(DepartmentModel department) async {
    await supabase.from('departments').insert({
      'hospital_id': department.hospitalId,
      'name': department.name,
      'description': department.description,
    });
  }
}
