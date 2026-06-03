import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<PatientModel> getProfile(String id);
  Future<List<DoctorModel>> searchDoctors(String query, {String? specialty, String? hospitalId});
  Future<void> bookAppointment(String patientId, String doctorId, DateTime time, String reason);
  Future<List<AppointmentModel>> getAppointments(String patientId);
  Future<void> cancelAppointment(String appointmentId);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final SupabaseClient supabase;
  PatientRemoteDataSourceImpl(this.supabase);

  @override
  Future<PatientModel> getProfile(String id) async {
    final response = await supabase
        .from('patients')
        .select('*, profiles(*)')
        .eq('id', id)
        .single();
    return PatientModel.fromJson({
      ...response,
      'full_name': response['profiles']['full_name'],
      'phone_number': response['profiles']['phone_number'],
      'avatar_url': response['profiles']['avatar_url'],
    });
  }

  @override
  Future<List<DoctorModel>> searchDoctors(String query, {String? specialty, String? hospitalId}) async {
    var request = supabase
        .from('doctors')
        .select('*, profiles!inner(full_name, avatar_url), hospitals(name), doctor_specialty_link!inner(doctor_specialties!inner(name))');
    
    if (query.isNotEmpty) {
      request = request.ilike('profiles.full_name', '%$query%');
    }
    
    if (specialty != null && specialty.isNotEmpty) {
      request = request.eq('doctor_specialty_link.doctor_specialties.name', specialty);
    }

    if (hospitalId != null && hospitalId.isNotEmpty) {
      request = request.eq('hospital_id', hospitalId);
    }
    
    final response = await request;
    return (response as List).map((json) => DoctorModel.fromJson(json)).toList();
  }

  @override
  Future<void> bookAppointment(String patientId, String doctorId, DateTime time, String reason) async {
    // Basic implementation - in real app, we'd need to find hospital_id and department_id
    final doctor = await supabase.from('doctors').select('hospital_id, department_id').eq('id', doctorId).single();
    
    await supabase.from('appointments').insert({
      'patient_id': patientId,
      'doctor_id': doctorId,
      'hospital_id': doctor['hospital_id'],
      'department_id': doctor['department_id'],
      'appointment_start_time': time.toIso8601String(),
      'appointment_end_time': time.add(const Duration(minutes: 30)).toIso8601String(),
      'reason': reason,
      'status': 'pending',
    });
  }

  @override
  Future<List<AppointmentModel>> getAppointments(String patientId) async {
    final response = await supabase
        .from('appointments')
        .select('*, doctors(profiles(full_name)), hospitals(name)')
        .eq('patient_id', patientId)
        .order('appointment_start_time', ascending: false);
    
    return (response as List).map((json) => AppointmentModel.fromJson(json)).toList();
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    await supabase.from('appointments').update({'status': 'cancelled'}).eq('id', appointmentId);
  }
}
