import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/video_call_controller.dart';
import '../../domain/usecases/video_call_usecases.dart';
import '../../domain/repositories/video_call_repository.dart';
import '../../data/repositories/video_call_repository_impl.dart';
import '../../data/datasources/video_call_remote_datasource.dart';

class VideoCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoCallRemoteDataSource>(
      () => VideoCallRemoteDataSourceImpl(Supabase.instance.client),
    );
    Get.lazyPut<VideoCallRepository>(
      () => VideoCallRepositoryImpl(Get.find<VideoCallRemoteDataSource>()),
    );
    Get.lazyPut(() => JoinCallUseCase(Get.find<VideoCallRepository>()));
    Get.lazyPut(() => LeaveCallUseCase(Get.find<VideoCallRepository>()));
    Get.lazyPut(() => SendMessageUseCase(Get.find<VideoCallRepository>()));
    Get.lazyPut(() => GetMessagesUseCase(Get.find<VideoCallRepository>()));

    Get.put(VideoCallController(
      joinCallUseCase: Get.find<JoinCallUseCase>(),
      leaveCallUseCase: Get.find<LeaveCallUseCase>(),
      sendMessageUseCase: Get.find<SendMessageUseCase>(),
      getMessagesUseCase: Get.find<GetMessagesUseCase>(),
    ));
  }
}
