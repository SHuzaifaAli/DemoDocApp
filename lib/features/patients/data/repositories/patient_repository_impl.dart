import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;
  PatientRepositoryImpl(this.remoteDataSource);

  @override
  Future<PatientEntity> getProfile(String id) => remoteDataSource.getProfile(id);

  @override
  Future<void> updateProfile(PatientEntity patient) async {
    // Implementation for updating profile
  }

  @override
  Future<List<DoctorEntity>> searchDoctors(String query) => remoteDataSource.searchDoctors(query);

  @override
  Future<void> bookAppointment(String patientId, String doctorId, DateTime time, String reason) =>
      remoteDataSource.bookAppointment(patientId, doctorId, time, reason);

  @override
  Future<List<AppointmentEntity>> getAppointmentHistory(String patientId) =>
      remoteDataSource.getAppointments(patientId);

  @override
  Future<void> cancelAppointment(String appointmentId) =>
      remoteDataSource.cancelAppointment(appointmentId);
}
