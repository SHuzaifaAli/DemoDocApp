class AdminStatsEntity {
  final int totalPatients;
  final int totalDoctors;
  final int totalAppointments;
  final double totalRevenue;

  AdminStatsEntity({
    required this.totalPatients,
    required this.totalDoctors,
    required this.totalAppointments,
    required this.totalRevenue,
  });
}

class HospitalEntity {
  final String id;
  final String name;
  final String address;
  final String? phoneNumber;

  HospitalEntity({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
  });
}

class AdminUserEntity {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;

  AdminUserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
  });
}

class DepartmentEntity {
  final String id;
  final String hospitalId;
  final String name;
  final String? description;

  DepartmentEntity({
    required this.id,
    required this.hospitalId,
    required this.name,
    this.description,
  });
}
