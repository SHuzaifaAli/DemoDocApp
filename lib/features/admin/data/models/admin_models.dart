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
    final profile = json['profiles'] as Map<String, dynamic>?;
    final role = json['roles'] as Map<String, dynamic>?;
    
    return AdminUserModel(
      id: json['user_id'] ?? '',
      fullName: profile?['full_name'] ?? 'No Name',
      email: profile?['email'] ?? 'No Email', // Note: Ensure email is fetched if stored in profiles
      role: role?['name'] ?? 'Unknown',
      isActive: profile?['status'] == 'active',
    );
  }
}
