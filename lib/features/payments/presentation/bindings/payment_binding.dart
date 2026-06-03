import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/payment_controller.dart';
import '../../domain/usecases/payment_usecases.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/datasources/payment_remote_datasource.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentRemoteDataSource>(
      () => PaymentRemoteDataSourceImpl(Supabase.instance.client),
    );
    Get.lazyPut<PaymentRepository>(
      () => PaymentRepositoryImpl(Get.find<PaymentRemoteDataSource>()),
    );
    Get.lazyPut(() => InitiatePaymentUseCase(Get.find<PaymentRepository>()));
    Get.lazyPut(() => ConfirmPaymentUseCase(Get.find<PaymentRepository>()));
    Get.lazyPut(() => GetPaymentHistoryUseCase(Get.find<PaymentRepository>()));

    Get.lazyPut(
      () => PaymentController(
        initiatePaymentUseCase: Get.find<InitiatePaymentUseCase>(),
        confirmPaymentUseCase: Get.find<ConfirmPaymentUseCase>(),
      ),
    );
  }
}
