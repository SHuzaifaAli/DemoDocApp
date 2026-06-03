import '../entities/patient_entity.dart';

abstract class PatientRepository {
  Future<PatientEntity> getProfile(String id);
  Future<void> updateProfile(PatientEntity patient);
  Future<List<DoctorEntity>> searchDoctors(String query);
  Future<void> bookAppointment(String patientId, String doctorId, DateTime time, String reason);
  Future<List<AppointmentEntity>> getAppointmentHistory(String patientId);
  Future<void> cancelAppointment(String appointmentId);
}
