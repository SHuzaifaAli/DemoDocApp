import '../entities/payment_entities.dart';
import '../repositories/payment_repository.dart';

class InitiatePaymentUseCase {
  final PaymentRepository repository;
  InitiatePaymentUseCase(this.repository);
  Future<PaymentEntity> execute(String appointmentId, double amount, PaymentMethod method) =>
      repository.initiatePayment(appointmentId, amount, method);
}

class ConfirmPaymentUseCase {
  final PaymentRepository repository;
  ConfirmPaymentUseCase(this.repository);
  Future<void> execute(String paymentId) => repository.confirmPayment(paymentId);
}

class GetPaymentHistoryUseCase {
  final PaymentRepository repository;
  GetPaymentHistoryUseCase(this.repository);
  Future<List<PaymentEntity>> execute(String userId) => repository.getPaymentHistory(userId);
}
