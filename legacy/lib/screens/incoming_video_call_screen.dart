import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/theme_service.dart';
import '../widgets/preview_video_view.dart';
import '../widgets/video_quality_indicator.dart';

/// Incoming video call screen
///
/// Displays full-screen modal for incoming video calls with answer/decline options.
///
/// ## Layout
///
/// ```
/// ┌─────────────────────────────────────────┐
/// │                                         │
/// │  [Caller Avatar]                        │
/// │  (large circular, 120dp)                │
/// │                                         │
/// │  John Doe                               │
/// │  +1 (555) 123-4567                      │
/// │  "Video Call"                           │
/// │                                         │
/// │  [PreviewVideoView]                     │
/// │  (small PiP, 80x120)                    │
/// │                                         │
/// │  ┌─────────────┐ ┌─────────────┐       │
/// │  │  [Decline]  │ │  [Answer]   │       │
/// │  │     ○       │ │     ○       │       │
/// │  │   Red       │ │   Green     │       │
/// │  └─────────────┘ └─────────────┘       │
/// │                                         │
/// └─────────────────────────────────────────┘
/// ```
///
/// ## Accessibility
///
/// - Large touch targets (72x72dp for answer/decline)
/// - Semantic labels for screen readers
/// - High contrast mode support
/// - Vibration pattern for incoming call
class IncomingVideoCallScreen extends StatefulWidget {
  /// Caller's name
  final String callerName;

  /// Caller's phone number or SIP address
  final String callerNumber;

  /// Caller's avatar URL (optional)
  final String? avatarUrl;

  /// Whether this is a video call (vs audio-only)
  final bool isVideoCall;

  /// Callback when call is answered
  final VoidCallback onAnswer;

  /// Callback when call is declined
  final VoidCallback onDecline;

  /// Auto-timeout in seconds (0 = no timeout)
  final int autoTimeoutSeconds;

  /// Callback when timeout occurs
  final VoidCallback? onTimeout;

  const IncomingVideoCallScreen({
    Key? key,
    required this.callerName,
    required this.callerNumber,
    this.avatarUrl,
    this.isVideoCall = true,
    required this.onAnswer,
    required this.onDecline,
    this.autoTimeoutSeconds = 30,
    this.onTimeout,
  }) : super(key: key);

  @override
  State<IncomingVideoCallScreen> createState() => _IncomingVideoCallScreenState();
}

class _IncomingVideoCallScreenState extends State<IncomingVideoCallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Pulse animation for answer button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Start countdown timer
    if (widget.autoTimeoutSeconds > 0) {
      _remainingSeconds = widget.autoTimeoutSeconds;
      _startCountdown();
    }

    // Trigger vibration
    _triggerVibration();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        _startCountdown();
      } else if (mounted && _remainingSeconds == 0) {
        widget.onTimeout?.call();
      }
    });
  }

  void _triggerVibration() {
    // Vibration pattern: vibrate 500ms, pause 500ms, repeat
    // In production, use Vibration plugin
    debugPrint('Triggering vibration for incoming call');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A237E), // Deep blue
              const Color(0xFF0D47A1), // Medium blue
              themeService.isDarkMode
                  ? const Color(0xFF121212)
                  : const Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section: caller info
              Expanded(
                flex: 3,
                child: _buildCallerInfo(),
              ),

              // Middle section: preview and quality
              Expanded(
                flex: 2,
                child: _buildPreviewSection(),
              ),

              // Bottom section: answer/decline buttons
              _buildActionButtons(),

              // Timeout indicator
              if (widget.autoTimeoutSeconds > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildTimeoutIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallerInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: widget.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    widget.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                  ),
                )
              : _buildAvatarPlaceholder(),
        ),

        const SizedBox(height: 24),

        // Caller name
        Text(
          widget.callerName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Caller number
        Text(
          widget.callerNumber,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Call type indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isVideoCall ? Icons.videocam : Icons.call,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isVideoCall ? 'Video Call' : 'Audio Call',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Incoming call indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_in_talk,
              color: Colors.green[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Incoming call...',
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isVideoCall) ...[
          // Local preview (small PiP for incoming call)
          SizedBox(
            width: 80,
            height: 120,
            child: PreviewVideoView(
              width: 80,
              height: 120,
              draggable: false,
              doubleTapToToggle: false,
            ),
          ),
          const SizedBox(height: 16),

          // Video quality indicator
          const CompactVideoQualityIndicator(
            quality: VideoQuality.unknown,
          ),
        ] else ...[
          // Audio call - show icon
          Icon(
            Icons.phone_android,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Decline button
          Semantics(
            label: 'Decline call',
            hint: 'Double-tap to decline the incoming call',
            button: true,
            child: _buildActionButton(
              icon: Icons.call_end,
              color: Colors.red,
              label: 'Decline',
              onPressed: widget.onDecline,
            ),
          ),

          // Answer button
          Semantics(
            label: 'Answer call',
            hint: 'Double-tap to answer the incoming video call',
            button: true,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: _buildActionButton(
                icon: widget.isVideoCall ? Icons.videocam : Icons.call,
                color: Colors.green,
                label: 'Answer',
                onPressed: widget.onAnswer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 36, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 72,
              minHeight: 72,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeoutIndicator() {
    return Text(
      'Call will be declined in $_remainingSeconds seconds',
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 12,
      ),
    );
  }
}

/// Video call screen for active calls
class ActiveVideoCallScreen extends StatelessWidget {
  final String callerName;
  final String callerNumber;
  final Duration callDuration;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideoOn;
  final bool isOnHold;
  final VoidCallback onEndCall;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleHold;
  final VoidCallback onShowMore;

  const ActiveVideoCallScreen({
    Key? key,
    required this.callerName,
    required this.callerNumber,
    required this.callDuration,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Remote video (full screen)
          const Positioned.fill(
            child: ColoredBox(color: Colors.black),
            // In production: RemoteVideoView(windowId: call.remoteWindowId)
          ),

          // Local preview (PiP)
          Positioned(
            top: 60,
            right: 16,
            child: SizedBox(
              width: 120,
              height: 160,
              child: PreviewVideoView(),
            ),
          ),

          // Call info overlay (top)
          Positioned(
            top: 60,
            left: 16,
            child: _buildCallInfoOverlay(),
          ),

          // Video quality indicator (top-right, below PiP)
          Positioned(
            top: 230,
            right: 16,
            child: const CompactVideoQualityIndicator(
              quality: VideoQuality.good,
            ),
          ),

          // Controls (bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoCallControls(
              isMuted: isMuted,
              isSpeakerOn: isSpeakerOn,
              isVideoOn: isVideoOn,
              isOnHold: isOnHold,
              onEndCall: onEndCall,
              onToggleMute: onToggleMute,
              onToggleSpeaker: onToggleSpeaker,
              onToggleVideo: onToggleVideo,
              onToggleHold: onToggleHold,
              onShowMore: onShowMore,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallInfoOverlay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            callerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            callerNumber,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDuration(callDuration),
            style: TextStyle(
              color: Colors.green[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

// Import the controls widget
import '../widgets/video_call_controls.dart';
