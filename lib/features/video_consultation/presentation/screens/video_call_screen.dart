import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/video_call_controller.dart';

class VideoCallScreen extends GetView<VideoCallController> {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildRemoteVideo(),
          _buildLocalVideo(),
          _buildToolbar(),
          _buildChatOverlay(),
        ],
      ),
    );
  }

  Widget _buildRemoteVideo() {
    return Obx(() {
      if (controller.remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: createAgoraRtcEngine(),
            canvas: VideoCanvas(uid: controller.remoteUid),
            connection: const RtcConnection(channelId: 'test'), // Should be dynamic
          ),
        );
      } else {
        return const Center(
          child: Text(
            'Waiting for other participant...',
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    });
  }

  Widget _buildLocalVideo() {
    return Positioned(
      top: 40,
      right: 20,
      child: SizedBox(
        width: 120,
        height: 160,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Obx(() => controller.isJoined
              ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: createAgoraRtcEngine(),
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
              : Container(color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: controller.isMuted ? Icons.mic_off : Icons.mic,
            onPressed: controller.toggleMute,
            color: controller.isMuted ? Colors.red : Colors.white24,
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: Icons.call_end,
            onPressed: controller.endCall,
            color: Colors.red,
            iconColor: Colors.white,
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: controller.isCameraOff ? Icons.videocam_off : Icons.videocam,
            onPressed: controller.toggleCamera,
            color: controller.isCameraOff ? Colors.red : Colors.white24,
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: Icons.switch_camera,
            onPressed: controller.switchCamera,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    Color? iconColor,
  }) {
    return Obx(() => RawMaterialButton(
          onPressed: onPressed,
          shape: const CircleBorder(),
          elevation: 2.0,
          fillColor: color ?? Colors.white24,
          padding: const EdgeInsets.all(12.0),
          child: Icon(icon, color: iconColor ?? Colors.white, size: 28.0),
        ));
  }

  Widget _buildChatOverlay() {
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  reverse: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[controller.messages.length - 1 - index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${msg.senderName}: ${msg.message}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  },
                )),
          ),
          const SizedBox(height: 8),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    final textController = TextEditingController();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Type a message...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.black54,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.blue,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white, size: 20),
            onPressed: () {
              controller.sendChat(textController.text);
              textController.clear();
            },
          ),
        ),
      ],
    );
  }
}
