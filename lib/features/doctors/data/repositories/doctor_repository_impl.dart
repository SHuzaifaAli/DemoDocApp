import '../../domain/entities/doctor_profile_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_datasource.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;
  DoctorRepositoryImpl(this.remoteDataSource);

  @override
  Future<DoctorProfileEntity> getProfile(String id) => remoteDataSource.getProfile(id);

  @override
  Future<List<DoctorAppointmentEntity>> getAppointments(String doctorId) =>
      remoteDataSource.getAppointments(doctorId);

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) =>
      remoteDataSource.updateAppointmentStatus(appointmentId, status);

  @override
  Future<void> addMedicalRecord(String patientId, String doctorId, String notes) =>
      remoteDataSource.addMedicalRecord(patientId, doctorId, notes);

  @override
  Future<void> rescheduleAppointment(String appointmentId, DateTime newTime) =>
      remoteDataSource.rescheduleAppointment(appointmentId, newTime);

  @override
  Future<List<PatientRecordEntity>> getPatientHistory(String patientId) async {
    // Implementation for fetching history
    return [];
  }
}
