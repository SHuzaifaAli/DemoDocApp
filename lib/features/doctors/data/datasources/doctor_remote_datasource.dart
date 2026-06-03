import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/doctor_profile_model.dart';

abstract class DoctorRemoteDataSource {
  Future<DoctorProfileModel> getProfile(String id);
  Future<List<DoctorAppointmentModel>> getAppointments(String doctorId);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
  Future<void> addMedicalRecord(String patientId, String doctorId, String notes);
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final SupabaseClient supabase;
  DoctorRemoteDataSourceImpl(this.supabase);

  @override
  Future<DoctorProfileModel> getProfile(String id) async {
    final response = await supabase
        .from('doctors')
        .select('*, profiles(full_name, avatar_url), hospitals(name), doctor_specialty_link(doctor_specialties(name))')
        .eq('id', id)
        .single();
    return DoctorProfileModel.fromJson(response);
  }

  @override
  Future<List<DoctorAppointmentModel>> getAppointments(String doctorId) async {
    final response = await supabase
        .from('appointments')
        .select('*, patients(profiles(full_name))')
        .eq('doctor_id', doctorId)
        .order('appointment_start_time', ascending: true);
    
    return (response as List).map((json) => DoctorAppointmentModel.fromJson(json)).toList();
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await supabase.from('appointments').update({'status': status}).eq('id', appointmentId);
  }

  @override
  Future<void> addMedicalRecord(String patientId, String doctorId, String notes) async {
    await supabase.from('medical_records').insert({
      'patient_id': patientId,
      'doctor_id': doctorId,
      'notes': notes,
    });
  }
}
