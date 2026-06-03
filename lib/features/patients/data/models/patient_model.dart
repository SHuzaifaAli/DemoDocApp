import '../../domain/entities/patient_entity.dart';

class PatientModel extends PatientEntity {
  PatientModel({
    required super.id,
    required super.fullName,
    super.email,
    super.phoneNumber,
    super.dateOfBirth,
    super.gender,
    super.bloodGroup,
    super.address,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'],
      phoneNumber: json['phone_number'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      gender: json['gender'],
      bloodGroup: json['blood_group'],
      address: json['address'],
    );
  }
}

class DoctorModel extends DoctorEntity {
  DoctorModel({
    required super.id,
    required super.fullName,
    super.specialty,
    super.hospitalName,
    super.consultationFee,
    super.avatarUrl,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'],
      fullName: json['profiles']['full_name'] ?? '',
      specialty: json['doctor_specialty_link'] != null && json['doctor_specialty_link'].isNotEmpty
          ? json['doctor_specialty_link'][0]['doctor_specialties']['name']
          : 'General',
      hospitalName: json['hospitals'] != null ? json['hospitals']['name'] : 'Unknown',
      consultationFee: (json['consultation_fee'] as num?)?.toDouble(),
      avatarUrl: json['profiles']['avatar_url'],
    );
  }
}

class AppointmentModel extends AppointmentEntity {
  AppointmentModel({
    required super.id,
    required super.doctorName,
    required super.hospitalName,
    required super.appointmentTime,
    required super.status,
    super.reason,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      doctorName: json['doctors']['profiles']['full_name'] ?? '',
      hospitalName: json['hospitals']['name'] ?? '',
      appointmentTime: DateTime.parse(json['appointment_start_time']),
      status: json['status'],
      reason: json['reason'],
    );
  }
}
