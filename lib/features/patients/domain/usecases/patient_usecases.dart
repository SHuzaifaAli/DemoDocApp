import '../entities/patient_entity.dart';
import '../repositories/patient_repository.dart';

class GetPatientProfileUseCase {
  final PatientRepository repository;
  GetPatientProfileUseCase(this.repository);
  Future<PatientEntity> execute(String id) => repository.getProfile(id);
}

class SearchDoctorsUseCase {
  final PatientRepository repository;
  SearchDoctorsUseCase(this.repository);
  Future<List<DoctorEntity>> execute(String query, {String? specialty, String? hospitalId}) => 
      repository.searchDoctors(query, specialty: specialty, hospitalId: hospitalId);
}

class BookAppointmentUseCase {
  final PatientRepository repository;
  BookAppointmentUseCase(this.repository);
  Future<void> execute(String patientId, String doctorId, DateTime time, String reason) =>
      repository.bookAppointment(patientId, doctorId, time, reason);
}

class GetAppointmentHistoryUseCase {
  final PatientRepository repository;
  GetAppointmentHistoryUseCase(this.repository);
  Future<List<AppointmentEntity>> execute(String patientId) => repository.getAppointmentHistory(patientId);
}

class CancelAppointmentUseCase {
  final PatientRepository repository;
  CancelAppointmentUseCase(this.repository);
  Future<void> execute(String appointmentId) => repository.cancelAppointment(appointmentId);
}
