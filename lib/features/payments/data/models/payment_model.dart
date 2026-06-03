import '../../domain/entities/payment_entities.dart';

class PaymentModel extends PaymentEntity {
  PaymentModel({
    required super.id,
    required super.appointmentId,
    required super.amount,
    required super.currency,
    required super.status,
    required super.method,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      appointmentId: json['appointment_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: PaymentStatus.values.firstWhere((e) => e.name == json['status']),
      method: PaymentMethod.values.firstWhere((e) => e.name == json['method']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'method': method.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
