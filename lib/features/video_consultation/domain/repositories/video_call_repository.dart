import '../entities/video_call_entity.dart';

abstract class VideoCallRepository {
  Future<VideoCallEntity> joinCall(String appointmentId);
  Future<void> leaveCall();
  Future<void> sendMessage(String appointmentId, String message);
  Stream<List<ChatMessageEntity>> getMessages(String appointmentId);
}
