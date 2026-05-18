import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class AgoraVideoCallScreen extends ConsumerStatefulWidget {
  const AgoraVideoCallScreen({super.key, required this.channelName});
  final String channelName;

  @override
  ConsumerState<AgoraVideoCallScreen> createState() => _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends ConsumerState<AgoraVideoCallScreen> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;
  String? _error;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Future<void> _initAgora() async {
    try {
      // Fetch Agora token from backend
      final client = ref.read(apiClientProvider);
      final res = await client.post(ApiEndpoints.agoraToken, data: {'channelName': widget.channelName});
      final data = res.data as Map<String, dynamic>;
      _token = data['token'] as String?;

      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: AppConstants.agoraAppId));

      _engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() => _isJoined = true);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() => _remoteUid = null);
        },
        onError: (err, msg) {
          setState(() => _error = msg);
        },
      ));

      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine.enableVideo();
      await _engine.startPreview();

      await _engine.joinChannel(
        token: _token ?? '',
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (full screen)
            if (_remoteUid != null)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(uid: _remoteUid!),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              )
            else
              _buildWaitingScreen(),

            // Local video (picture-in-picture)
            if (_isJoined && !_isCameraOff)
              Positioned(
                top: 16,
                right: 16,
                width: 120,
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),

            // Error overlay
            if (_error != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.red.withOpacity(0.8),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Controls
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: _buildControls(),
            ),

            // Channel info
            Positioned(
              top: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isJoined) Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 6), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                        Text(
                          _isJoined ? 'Connected' : 'Connecting...',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_call, size: 80, color: Colors.white54),
            SizedBox(height: 16),
            Text('Waiting for participant...', style: TextStyle(color: Colors.white70, fontSize: 18)),
            SizedBox(height: 8),
            Text('Make sure the other person has joined', style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: _isMuted ? Icons.mic_off : Icons.mic,
          label: _isMuted ? 'Unmute' : 'Mute',
          color: _isMuted ? Colors.red : Colors.white,
          onTap: () async {
            await _engine.muteLocalAudioStream(!_isMuted);
            setState(() => _isMuted = !_isMuted);
          },
        ),
        const SizedBox(width: 16),
        _ControlButton(
          icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
          label: _isCameraOff ? 'Camera On' : 'Camera Off',
          color: _isCameraOff ? Colors.red : Colors.white,
          onTap: () async {
            await _engine.muteLocalVideoStream(!_isCameraOff);
            setState(() => _isCameraOff = !_isCameraOff);
          },
        ),
        const SizedBox(width: 16),
        _ControlButton(
          icon: Icons.call_end,
          label: 'End',
          color: Colors.white,
          backgroundColor: Colors.red,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        _ControlButton(
          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
          label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
          color: Colors.white,
          onTap: () async {
            await _engine.setEnableSpeakerphone(!_isSpeakerOn);
            setState(() => _isSpeakerOn = !_isSpeakerOn);
          },
        ),
        const SizedBox(width: 16),
        _ControlButton(
          icon: Icons.flip_camera_ios,
          label: 'Flip',
          color: Colors.white,
          onTap: () async {
            await _engine.switchCamera();
            setState(() => _isFrontCamera = !_isFrontCamera);
          },
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.backgroundColor,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
