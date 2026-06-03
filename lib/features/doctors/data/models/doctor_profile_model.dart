import '../../domain/entities/doctor_profile_entity.dart';

class DoctorProfileModel extends DoctorProfileEntity {
  DoctorProfileModel({
    required super.id,
    required super.fullName,
    required super.specialty,
    required super.hospitalName,
    super.bio,
    super.avatarUrl,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    return DoctorProfileModel(
      id: json['id'],
      fullName: json['profiles']['full_name'] ?? '',
      specialty: json['doctor_specialty_link'] != null && json['doctor_specialty_link'].isNotEmpty
          ? json['doctor_specialty_link'][0]['doctor_specialties']['name']
          : 'General',
      hospitalName: json['hospitals'] != null ? json['hospitals']['name'] : 'Unknown',
      bio: json['bio'],
      avatarUrl: json['profiles']['avatar_url'],
    );
  }
}

class DoctorAppointmentModel extends DoctorAppointmentEntity {
  DoctorAppointmentModel({
    required super.id,
    required super.patientName,
    required super.appointmentTime,
    required super.status,
    super.reason,
  });

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentModel(
      id: json['id'],
      patientName: json['patients']['profiles']['full_name'] ?? '',
      appointmentTime: DateTime.parse(json['appointment_start_time']),
      status: json['status'],
      reason: json['reason'],
    );
  }
}
