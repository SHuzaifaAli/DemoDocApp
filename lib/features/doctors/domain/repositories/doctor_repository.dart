import '../entities/doctor_profile_entity.dart';

abstract class DoctorRepository {
  Future<DoctorProfileEntity> getProfile(String id);
  Future<List<DoctorAppointmentEntity>> getAppointments(String doctorId);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
  Future<void> addMedicalRecord(String patientId, String doctorId, String notes);
  Future<void> rescheduleAppointment(String appointmentId, DateTime newTime);
  Future<List<PatientRecordEntity>> getPatientHistory(String patientId);
  Future<void> updateAvailability(String doctorId, List<Map<String, dynamic>> slots);
}
