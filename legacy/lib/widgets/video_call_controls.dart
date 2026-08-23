import 'package:flutter/material.dart';

/// Call control button configuration
class CallControlButton {
  final IconData iconOn;
  final IconData iconOff;
  final String labelOn;
  final String labelOff;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback? onPressed;
  final bool isActive;

  const CallControlButton({
    required this.iconOn,
    required this.iconOff,
    required this.labelOn,
    required this.labelOff,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white70,
    this.onPressed,
    this.isActive = false,
  });
}

/// Video call controls bar
///
/// Displays call control buttons during video calls.
/// Includes: End Call, Mute, Speaker, Video, Hold, and More options.
///
/// ## Layout
///
/// ```
/// [Mute] [Speaker] [Video] [END] [Hold] [More]
/// ```
///
/// ## Accessibility
///
/// - Minimum touch target: 48x48dp (exceeds WCAG 44x44dp)
/// - End call button: 64x64dp (primary action)
/// - Semantic labels for all buttons
/// - High contrast mode support
class VideoCallControls extends StatelessWidget {
  /// Microphone muted state
  final bool isMuted;

  /// Speaker mode active
  final bool isSpeakerOn;

  /// Video transmission active
  final bool isVideoOn;

  /// Call on hold
  final bool isOnHold;

  /// End call action
  final VoidCallback onEndCall;

  /// Toggle mute action
  final VoidCallback onToggleMute;

  /// Toggle speaker action
  final VoidCallback onToggleSpeaker;

  /// Toggle video action
  final VoidCallback onToggleVideo;

  /// Toggle hold action
  final VoidCallback onToggleHold;

  /// Show more options action
  final VoidCallback onShowMore;

  /// Button size for secondary controls
  final double buttonSize;

  /// End call button size
  final double endCallButtonSize;

  /// Show labels under buttons
  final bool showLabels;

  const VideoCallControls({
    Key? key,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isVideoOn,
    required this.isOnHold,
    required this.onEndCall,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    required this.onToggleVideo,
    required this.onToggleHold,
    required this.onShowMore,
    this.buttonSize = 48,
    this.endCallButtonSize = 64,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute button
                _buildControlButton(
                  icon: isMuted ? Icons.mic_off : Icons.mic,
                  label: isMuted ? 'Unmute' : 'Mute',
                  isActive: isMuted,
                  activeColor: Colors.red,
                  onPressed: onToggleMute,
                  size: buttonSize,
                ),

                // Speaker button
                _buildControlButton(
                  icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  label: isSpeakerOn ? 'Speaker' : 'Earpiece',
                  isActive: isSpeakerOn,
                  activeColor: Colors.blue,
                  onPressed: onToggleSpeaker,
                  size: buttonSize,
                ),

                // Video button
                _buildControlButton(
                  icon: isVideoOn ? Icons.videocam : Icons.videocam_off,
                  label: isVideoOn ? 'Video Off' : 'Video On',
                  isActive: isVideoOn,
                  activeColor: Colors.green,
                  onPressed: onToggleVideo,
                  size: buttonSize,
                ),

                // End call button (center, larger)
                _buildEndCallButton(),

                // Hold button
                _buildControlButton(
                  icon: isOnHold ? Icons.play_arrow : Icons.pause,
                  label: isOnHold ? 'Resume' : 'Hold',
                  isActive: isOnHold,
                  activeColor: Colors.orange,
                  onPressed: onToggleHold,
                  size: buttonSize,
                ),

                // More button
                _buildControlButton(
                  icon: Icons.more_horiz,
                  label: 'More',
                  isActive: false,
                  onPressed: onShowMore,
                  size: buttonSize,
                ),
              ],
            ),
            if (showLabels) ...[
              const SizedBox(height: 8),
              _buildCallInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    Color? activeColor,
    required VoidCallback onPressed,
    double size = 48,
  }) {
    return Semantics(
      label: label,
      button: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isActive
                  ? (activeColor ?? Colors.white).withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? (activeColor ?? Colors.white)
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: isActive
                    ? (activeColor ?? Colors.white)
                    : Colors.white.withOpacity(0.7),
                size: size * 0.5,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: size,
                minHeight: size,
              ),
            ),
          ),
          if (showLabels) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEndCallButton() {
    return Semantics(
      label: 'End call',
      hint: 'Double-tap to end the current video call',
      button: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: endCallButtonSize,
            height: endCallButtonSize,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              onPressed: onEndCall,
              icon: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 32,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: endCallButtonSize,
                minHeight: endCallButtonSize,
              ),
            ),
          ),
          if (showLabels) ...[
            const SizedBox(height: 4),
            const Text(
              'End',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCallInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.call,
          size: 14,
          color: Colors.green[400],
        ),
        const SizedBox(width: 4),
        Text(
          'Video call in progress',
          style: TextStyle(
            color: Colors.green[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Compact version of video call controls
///
/// For use in smaller spaces or when minimal controls are needed.
class CompactVideoCallControls extends StatelessWidget {
  final bool isMuted;
  final bool isVideoOn;
  final VoidCallback onEndCall;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleVideo;

  const CompactVideoCallControls({
    Key? key,
    required this.isMuted,
    required this.isVideoOn,
    required this.onEndCall,
    required this.onToggleMute,
    required this.onToggleVideo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mute
          _buildSmallButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            isActive: isMuted,
            onPressed: onToggleMute,
          ),
          const SizedBox(width: 8),

          // Video
          _buildSmallButton(
            icon: isVideoOn ? Icons.videocam : Icons.videocam_off,
            isActive: isVideoOn,
            onPressed: onToggleVideo,
          ),
          const SizedBox(width: 8),

          // End call
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onEndCall,
              icon: const Icon(Icons.call_end, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      label: isActive ? 'Turn on' : 'Turn off',
      button: true,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: isActive ? Colors.white : Colors.white70,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
        ),
      ),
    );
  }
}
