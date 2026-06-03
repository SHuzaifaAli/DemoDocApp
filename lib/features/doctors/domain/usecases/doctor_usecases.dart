import '../entities/doctor_profile_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorProfileUseCase {
  final DoctorRepository repository;
  GetDoctorProfileUseCase(this.repository);
  Future<DoctorProfileEntity> execute(String id) => repository.getProfile(id);
}

class GetDoctorAppointmentsUseCase {
  final DoctorRepository repository;
  GetDoctorAppointmentsUseCase(this.repository);
  Future<List<DoctorAppointmentEntity>> execute(String doctorId) => repository.getAppointments(doctorId);
}

class UpdateAppointmentStatusUseCase {
  final DoctorRepository repository;
  UpdateAppointmentStatusUseCase(this.repository);
  Future<void> execute(String appointmentId, String status) => repository.updateAppointmentStatus(appointmentId, status);
}

class AddMedicalRecordUseCase {
  final DoctorRepository repository;
  AddMedicalRecordUseCase(this.repository);
  Future<void> execute(String patientId, String doctorId, String notes) =>
      repository.addMedicalRecord(patientId, doctorId, notes);
}
