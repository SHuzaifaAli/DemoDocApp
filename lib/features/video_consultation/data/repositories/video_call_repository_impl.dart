import '../../domain/entities/video_call_entity.dart';
import '../../domain/repositories/video_call_repository.dart';
import '../datasources/video_call_remote_datasource.dart';

class VideoCallRepositoryImpl implements VideoCallRepository {
  final VideoCallRemoteDataSource remoteDataSource;
  VideoCallRepositoryImpl(this.remoteDataSource);

  @override
  Future<VideoCallEntity> joinCall(String appointmentId) async {
    final data = await remoteDataSource.getCallToken(appointmentId);
    return VideoCallEntity(
      channelName: data['channelName'],
      token: data['token'],
      uid: data['uid'],
    );
  }

  @override
  Future<void> leaveCall() async {
    // Agora engine cleanup is handled in the controller
  }

  @override
  Future<void> sendMessage(String appointmentId, String message) async {
    await remoteDataSource.saveMessage(appointmentId, message);
  }

  @override
  Stream<List<ChatMessageEntity>> getMessages(String appointmentId) {
    return remoteDataSource.streamMessages(appointmentId);
  }
}
