import 'package:get/get.dart';
import '../../domain/entities/payment_entities.dart';
import '../../domain/usecases/payment_usecases.dart';

class PaymentController extends GetxController {
  final InitiatePaymentUseCase initiatePaymentUseCase;
  final ConfirmPaymentUseCase confirmPaymentUseCase;

  PaymentController({
    required this.initiatePaymentUseCase,
    required this.confirmPaymentUseCase,
  });

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  Future<void> processPayment(String appointmentId, double amount, PaymentMethod method) async {
    try {
      _isLoading.value = true;
      final payment = await initiatePaymentUseCase.execute(appointmentId, amount, method);
      
      // Here you would integrate the specific SDK logic (Stripe, JazzCash, EasyPaisa)
      // For demonstration, we'll simulate a successful transaction
      await Future.delayed(const Duration(seconds: 2));
      
      await confirmPaymentUseCase.execute(payment.id);
      Get.snackbar('Success', 'Payment of \$${amount.toStringAsFixed(2)} processed via ${method.name}');
      Get.back(); // Return to previous screen
    } catch (e) {
      Get.snackbar('Error', 'Payment failed: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
}
