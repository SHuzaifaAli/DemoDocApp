import '../../domain/entities/video_call_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel({
    required super.senderId,
    required super.senderName,
    required super.message,
    required super.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      senderId: json['sender_id'],
      senderName: json['sender_name'] ?? 'Unknown',
      message: json['message'],
      timestamp: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'sender_name': senderName,
      'message': message,
      'created_at': timestamp.toIso8601String(),
    };
  }
}
