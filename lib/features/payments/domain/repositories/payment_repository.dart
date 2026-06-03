import '../entities/payment_entities.dart';

abstract class PaymentRepository {
  Future<PaymentEntity> initiatePayment(String appointmentId, double amount, PaymentMethod method);
  Future<void> confirmPayment(String paymentId);
  Future<List<PaymentEntity>> getPaymentHistory(String userId);
}
