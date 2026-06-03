class VideoCallEntity {
  final String channelName;
  final String token;
  final int uid;
  final String? doctorName;
  final String? patientName;

  VideoCallEntity({
    required this.channelName,
    required this.token,
    required this.uid,
    this.doctorName,
    this.patientName,
  });
}

class ChatMessageEntity {
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;

  ChatMessageEntity({
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });
}
