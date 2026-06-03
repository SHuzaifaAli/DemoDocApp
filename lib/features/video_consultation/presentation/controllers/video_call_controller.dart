import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hospital_booking_management/core/constants/app_constants.dart';
import '../../domain/usecases/video_call_usecases.dart';
import '../../domain/entities/video_call_entity.dart';

class VideoCallController extends GetxController {
  final JoinCallUseCase joinCallUseCase;
  final LeaveCallUseCase leaveCallUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetMessagesUseCase getMessagesUseCase;

  VideoCallController({
    required this.joinCallUseCase,
    required this.leaveCallUseCase,
    required this.sendMessageUseCase,
    required this.getMessagesUseCase,
  });

  late RtcEngine _engine;
  final _remoteUid = RxnInt();
  int? get remoteUid => _remoteUid.value;

  final _isJoined = false.obs;
  bool get isJoined => _isJoined.value;

  final _isMuted = false.obs;
  bool get isMuted => _isMuted.value;

  final _isCameraOff = false.obs;
  bool get isCameraOff => _isCameraOff.value;

  final messages = <ChatMessageEntity>[].obs;
  late String _appointmentId;

  @override
  void onInit() {
    super.onInit();
    _appointmentId = Get.arguments['appointmentId'];
    _initAgora();
    _listenToMessages();
  }

  Future<void> _initAgora() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: AppConstants.agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _isJoined.value = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _remoteUid.value = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          _remoteUid.value = null;
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          _isJoined.value = false;
          _remoteUid.value = null;
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    final callData = await joinCallUseCase.execute(_appointmentId);
    await _engine.joinChannel(
      token: callData.token,
      channelId: callData.channelName,
      uid: callData.uid,
      options: const ChannelMediaOptions(),
    );
  }

  void _listenToMessages() {
    getMessagesUseCase.execute(_appointmentId).listen((newMessages) {
      messages.assignAll(newMessages);
    });
  }

  Future<void> sendChat(String text) async {
    if (text.trim().isEmpty) return;
    await sendMessageUseCase.execute(_appointmentId, text);
  }

  void toggleMute() {
    _isMuted.value = !_isMuted.value;
    _engine.muteLocalAudioStream(_isMuted.value);
  }

  void toggleCamera() {
    _isCameraOff.value = !_isCameraOff.value;
    _engine.muteLocalVideoStream(_isCameraOff.value);
  }

  void switchCamera() {
    _engine.switchCamera();
  }

  Future<void> endCall() async {
    await _engine.leaveChannel();
    await _engine.release();
    await leaveCallUseCase.execute();
    Get.back();
  }

  @override
  void onClose() {
    _engine.leaveChannel();
    _engine.release();
    super.onClose();
  }
}
