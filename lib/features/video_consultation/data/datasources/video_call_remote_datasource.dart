import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_call_model.dart';

abstract class VideoCallRemoteDataSource {
  Future<Map<String, dynamic>> getCallToken(String appointmentId);
  Future<void> saveMessage(String appointmentId, String message);
  Stream<List<ChatMessageModel>> streamMessages(String appointmentId);
}

class VideoCallRemoteDataSourceImpl implements VideoCallRemoteDataSource {
  final SupabaseClient supabase;
  VideoCallRemoteDataSourceImpl(this.supabase);

  @override
  Future<Map<String, dynamic>> getCallToken(String appointmentId) async {
    // In a real implementation, this would call an Edge Function to generate an Agora token
    // For now, we'll return a mock token and the appointment ID as the channel name
    return {
      'token': 'MOCK_TOKEN',
      'channelName': appointmentId,
      'uid': supabase.auth.currentUser?.id.hashCode ?? 0,
    };
  }

  @override
  Future<void> saveMessage(String appointmentId, String message) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from('consultation_chats').insert({
      'appointment_id': appointmentId,
      'sender_id': userId,
      'message': message,
    });
  }

  @override
  Stream<List<ChatMessageModel>> streamMessages(String appointmentId) {
    return supabase
        .from('consultation_chats')
        .stream(primaryKey: ['id'])
        .eq('appointment_id', appointmentId)
        .order('created_at')
        .map((data) => data.map((json) => ChatMessageModel.fromJson(json)).toList());
  }
}
