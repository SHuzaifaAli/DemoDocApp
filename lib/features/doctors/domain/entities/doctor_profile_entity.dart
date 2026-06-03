class DoctorProfileEntity {
  final String id;
  final String fullName;
  final String specialty;
  final String hospitalName;
  final String? bio;
  final String? avatarUrl;

  DoctorProfileEntity({
    required this.id,
    required this.fullName,
    required this.specialty,
    required this.hospitalName,
    this.bio,
    this.avatarUrl,
  });
}

class DoctorAppointmentEntity {
  final String id;
  final String patientName;
  final DateTime appointmentTime;
  final String status;
  final String? reason;

  DoctorAppointmentEntity({
    required this.id,
    required this.patientName,
    required this.appointmentTime,
    required this.status,
    this.reason,
  });
}

class PatientRecordEntity {
  final String id;
  final String patientId;
  final String doctorId;
  final String notes;
  final DateTime createdAt;

  PatientRecordEntity({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.notes,
    required this.createdAt,
  });
}
