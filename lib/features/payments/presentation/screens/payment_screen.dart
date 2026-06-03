import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_controller.dart';
import '../../domain/entities/payment_entities.dart';

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments;
    final String appointmentId = args['appointmentId'];
    final double amount = args['amount'];

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(amount),
            const SizedBox(height: 24),
            const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentMethodTile(PaymentMethod.stripe, 'Stripe (Credit/Debit Card)', Icons.credit_card, appointmentId, amount),
            _buildPaymentMethodTile(PaymentMethod.jazzcash, 'JazzCash', Icons.account_balance_wallet, appointmentId, amount),
            _buildPaymentMethodTile(PaymentMethod.easypaisa, 'EasyPaisa', Icons.account_balance_wallet_outlined, appointmentId, amount),
            const Spacer(),
            Obx(() => controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Amount', style: TextStyle(fontSize: 16)),
          Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method, String label, IconData icon, String appointmentId, double amount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => controller.processPayment(appointmentId, amount, method),
      ),
    );
  }
}
