class PatientEntity {
  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? address;

  PatientEntity({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.address,
  });
}

class DoctorEntity {
  final String id;
  final String fullName;
  final String? specialty;
  final String? hospitalName;
  final double? consultationFee;
  final String? avatarUrl;

  DoctorEntity({
    required this.id,
    required this.fullName,
    this.specialty,
    this.hospitalName,
    this.consultationFee,
    this.avatarUrl,
  });
}

class AppointmentEntity {
  final String id;
  final String doctorName;
  final String hospitalName;
  final DateTime appointmentTime;
  final String status;
  final String? reason;

  AppointmentEntity({
    required this.id,
    required this.doctorName,
    required this.hospitalName,
    required this.appointmentTime,
    required this.status,
    this.reason,
  });
}
