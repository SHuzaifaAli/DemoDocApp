import '../entities/video_call_entity.dart';
import '../repositories/video_call_repository.dart';

class JoinCallUseCase {
  final VideoCallRepository repository;
  JoinCallUseCase(this.repository);

  Future<VideoCallEntity> execute(String appointmentId) {
    return repository.joinCall(appointmentId);
  }
}

class LeaveCallUseCase {
  final VideoCallRepository repository;
  LeaveCallUseCase(this.repository);

  Future<void> execute() {
    return repository.leaveCall();
  }
}

class SendMessageUseCase {
  final VideoCallRepository repository;
  SendMessageUseCase(this.repository);

  Future<void> execute(String appointmentId, String message) {
    return repository.sendMessage(appointmentId, message);
  }
}

class GetMessagesUseCase {
  final VideoCallRepository repository;
  GetMessagesUseCase(this.repository);

  Stream<List<ChatMessageEntity>> execute(String appointmentId) {
    return repository.getMessages(appointmentId);
  }
}
