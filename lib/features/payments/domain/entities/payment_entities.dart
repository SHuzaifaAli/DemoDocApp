enum PaymentStatus { pending, completed, failed, refunded }
enum PaymentMethod { stripe, jazzcash, easypaisa }

class PaymentEntity {
  final String id;
  final String appointmentId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime createdAt;

  PaymentEntity({
    required this.id,
    required this.appointmentId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    required this.createdAt,
  });
}
