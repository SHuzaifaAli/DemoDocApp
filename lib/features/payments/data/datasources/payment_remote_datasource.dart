import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';
import '../../domain/entities/payment_entities.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> initiatePayment(String appointmentId, double amount, PaymentMethod method);
  Future<void> updatePaymentStatus(String paymentId, String status);
  Future<List<PaymentModel>> getPayments(String userId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient supabase;
  PaymentRemoteDataSourceImpl(this.supabase);

  @override
  Future<PaymentModel> initiatePayment(String appointmentId, double amount, PaymentMethod method) async {
    final response = await supabase.from('payments').insert({
      'appointment_id': appointmentId,
      'amount': amount,
      'method': method.name,
      'status': 'pending',
    }).select().single();
    
    return PaymentModel.fromJson(response);
  }

  @override
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    await supabase.from('payments').update({'status': status}).eq('id', paymentId);
  }

  @override
  Future<List<PaymentModel>> getPayments(String userId) async {
    // This query assumes a relationship through appointments
    final response = await supabase
        .from('payments')
        .select('*, appointments!inner(patient_id)')
        .eq('appointments.patient_id', userId);
    
    return (response as List).map((json) => PaymentModel.fromJson(json)).toList();
  }
}
