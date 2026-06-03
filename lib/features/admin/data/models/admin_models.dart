import '../../domain/entities/admin_entities.dart';

class AdminStatsModel extends AdminStatsEntity {
  AdminStatsModel({
    required super.totalPatients,
    required super.totalDoctors,
    required super.totalAppointments,
    required super.totalRevenue,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalPatients: json['total_patients'] ?? 0,
      totalDoctors: json['total_doctors'] ?? 0,
      totalAppointments: json['total_appointments'] ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class HospitalModel extends HospitalEntity {
  HospitalModel({
    required super.id,
    required super.name,
    required super.address,
    super.phoneNumber,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
    );
  }
}

class AdminUserModel extends AdminUserEntity {
  AdminUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    required super.isActive,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      fullName: json['profiles']['full_name'] ?? '',
      email: json['profiles']['email'] ?? '',
      role: json['roles']['name'] ?? 'Unknown',
      isActive: json['is_active'] ?? true,
    );
  }
}
