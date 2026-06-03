import '../../domain/entities/payment_entities.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<PaymentEntity> initiatePayment(String appointmentId, double amount, PaymentMethod method) =>
      remoteDataSource.initiatePayment(appointmentId, amount, method);

  @override
  Future<void> confirmPayment(String paymentId) =>
      remoteDataSource.updatePaymentStatus(paymentId, 'completed');

  @override
  Future<List<PaymentEntity>> getPaymentHistory(String userId) =>
      remoteDataSource.getPayments(userId);
}
